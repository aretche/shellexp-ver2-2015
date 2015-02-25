unit Inicializadores;

interface
	uses
	funciones, Auxiliares, tipos, BaseUnix, Unix, Unixtype, crt, SysUtils,DateUtils,users,unixutil;

    procedure iniciarvariables;
    procedure inicializarValores;
    procedure prompt;
    function Descifrador (cadena: string):comando;
    procedure limpiarEntrada (var vector: array of String);
    function multipleEntrada: boolean;
    function obtenerOperador: String;
	function obtenerEntrada: comando;
	function esInterno: boolean;
    procedure Lanzador;

implementation

	//inicia las variables internas que manejan el entorno del shell
    procedure iniciarvariables;
    begin	
		//Hace que el shell comience en home/Usuario
		home:='/home';
		olddir:=home;
		usuarioActual:=fpgetenv('USER');
		homeMasUsuarioActual:=(home+'/'+usuarioActual);
		//Establece como una direccion actual a home/Usuario
		directorio:=homeMasUsuarioActual;
		//Variable que se utiliza cuando hay mas de un parametro
	end;
	
	
	//Inicializa vectores internos que controlan los comandos ingresados
	procedure inicializarValores;
	begin
		Entrada:='';
		Operador:='';
		limpiarEntrada(comandos);
		setlength(dat,0);
		setlength(comandos,0);
		setlength(parteEntrada,0);
		hayRedireccion:=false;
		terminaProc:=false;
	end;


	//Muestra en pantalla el prompt
    procedure prompt;
    begin
		//Muestra usuario y equipo
		write(usuarioActual,'_@_',hostActual,':');
		//Agrega despues del usuario y equipo, separado con '~', la direccion actual
   	    if copy(directorio,1,length(homeMasUsuarioActual)) = homeMasUsuarioActual then
			write('~',copy(directorio,length(homeMasUsuarioActual)+1,length(directorio)))
		else write(directorio);
		//Este bloque determina si es un usuario ($) o es root(#).
		if (usuarioActual = 'root') then write('# ')	
		else write('$ ');	
	end;
	
	
	// Se le pasa un string en cadena y devuelve un array of string con
	// las palabras desde la pos 1 y el ultimo lugar vacio
	function Descifrador (cadena: string): comando;
	var	posicion,longitud: integer;
		subcadena: string;
		result: array of String;
		estado: boolean;
		
	begin
		estado:= true;
		posicion:= 1;
		longitud:= length(cadena);
	    SetLength(result, longitud + 1);
		repeat
			//Si encuentra algun espacio
			if Pos(' ', cadena) > 0 then
			begin
				//Mira que el espacio no este al principio
				if Pos(' ',cadena) <> 1 then
				begin
					//Obtiene la primer subcadena hasta el espacio
					subcadena:= Copy(cadena, 1, Pos(' ', cadena) - 1);
					//Deja como cadena la parte restante
					cadena:= Copy(cadena, Pos(' ',cadena),Length(cadena))
				end
				else 
				begin
					cadena:=Copy(cadena, 2, Length(cadena));
					estado:= false;	
				end;
			end
			//Si no hay ningun espacio en la cadena, asigna la subcadena y sale
			else
			begin
				subcadena:= cadena;
				cadena:= '';
			end;
			//Guarda la primer subcadena hallada antes del espacio en la posicion actual
			//Siempre y cuando no sea un espacio o un nulo que controla la variable estado.
			if (estado) then 
			begin
				result[posicion]:= subcadena;
				Inc(posicion);
			end;
		estado:=true;
		until cadena= '';
		SetLength(result, posicion);
		Descifrador:= result;
	end;
	
	
	//Deja limpio el vector de entrada para recibir una nueva posteriormente.
	procedure limpiarEntrada (var vector: array of String);
	var pos: integer;
	begin
		for pos:=1 to length(vector) do vector[pos]:='';
	end;
		
	
	//Verifica si en la linea ingresada no hay redireccionamiento con tuberias y/o archivos.	
	function multipleEntrada: boolean;
	var pos: integer;
	begin
		multipleEntrada:=false;
		for pos:=1 to length(comandos) do
		if (comandos[pos]='>>') or (comandos[pos]='>') or (comandos[pos]='|') then multipleEntrada:=true;
	end;
	
	
	//Obtiene el operador en caso de existir multiple entrada
	function obtenerOperador: String;
	var pos: integer;
	begin
		pos:=1;
		while (comandos[pos]='>>') and (comandos[pos]='>') and (comandos[pos]='|') do pos:=pos+1;
		obtenerOperador:=comandos[pos];
	end;
	
	
	procedure actualizarVector(pos: integer);
	var lugar: integer;
	begin
		lugar:=1;
		if (comandos[pos]<>'') then
		begin
			while (comandos[pos]<>'') do
			begin
				comandos[lugar]:=comandos[pos];
				lugar:=lugar+1;
				pos:=pos+1;
			end;
			setlength(comandos,lugar);
			comandos[lugar]:='';
		end
		else
		begin
			setlength(comandos,1);
			comandos[1]:='';
		end;
	end;	
	
	
	//Separa la linea ingresada en diferentes partes (comandos y signos de redireccionamiento)
	function obtenerEntrada: comando;
	var pos, i: integer;
		result: comando;
	begin
		pos:= 1;
		setLength(result,pos);
		limpiarEntrada(parteEntrada);
		if 	(comandos[1]='>>') or (comandos[1]='>') or (comandos[1]='|') then 
		begin
			operador:='';
			operador:=comandos[1];
			actualizarVector(2);
			pos:=1;
		end;
		while (comandos[pos]<>'') and (comandos[pos]<>'>>') and
			  (comandos[pos]<>'>') and (comandos[pos]<>'|') do   pos:=pos+1;
		setLength(result,pos-1);
		for i:=1 to pos-1 do result[i]:= comandos[i];
		actualizarVector(pos);
		obtenerEntrada:=result;
	end;
	
	
	//Determina si el comando ingresado es interno o externo
	function esInterno: boolean;
	begin
		if 	(parteEntrada[1] = 'mils') or (parteEntrada[1] = 'micd') or (parteEntrada[1] = 'mikill') or 
			(parteEntrada[1] = 'micat') or (parteEntrada[1] = 'mibg') or (parteEntrada[1] = 'mifg') or
			(parteEntrada[1] = 'mipwd') then esInterno:=true
		else esInterno:=false; 
	end;
	
	
	//Analiza la entrada del shell y define los parametros que debe tomar el procedimiento MiLs
	procedure LanzarMiLs;
	var cadena: String;
		tam: integer;
	begin
		if (length(parteEntrada)>3) then guardarMensaje('Error en la cantidad de parametros')
		else
		begin
			tam:= length(parteEntrada);
			case tam of
				1: 	begin mils ('<>', '<>'); end;
				2: 	begin
						cadena:= parteEntrada[2];
						if (copy(cadena,1,1)='-') then mils(cadena, '<>')
						else
						begin
							if verificarRuta(cadena) then mils ('<>', cadena)
							else writeln('la ruta ingresada no es valida');
						end;
					end;
				3:	begin
						if verificarRuta(parteEntrada[3]) then mils (parteEntrada[2], parteEntrada[3])
						else writeln('la ruta ingresada no es valida');
					end;
			end;
		end;
	end;
	
	
	//Analiza la entrada del shell y define los parametros que debe tomar el procedimiento MiCat
	procedure lanzarMiCat;
	var rut1, rut2 :boolean;
		tam: integer;
	begin
		tam:= length(parteEntrada);
		if (tam>3) then guardarMensaje('Error en la cantidad de parametros')
		else
		begin
			case tam of
				1: 	begin micat ('<>','<>'); end;
				2: 	begin
						if (verificarRutaArchivo(parteEntrada[2])) then micat (parteEntrada[2],'<>')
						else
						begin
							guardarMensaje('Error ');
							guardarMensaje(parteEntrada[2]);
							guardarMensaje(': No existe el archivo o el directorio');
						end;
					end;
				3:	begin
						rut1:=verificarRutaArchivo(parteEntrada[2]);
						rut2:=verificarRutaArchivo(parteEntrada[3]);
						if (rut1 and rut2) then micat (parteEntrada[2],parteEntrada[3])
						else
						begin
							guardarMensaje('Error ');
							if ((not rut1) and (not rut2)) then guardarMensaje(': Ninguno de los directorios son correctos')
							else
							begin
								if rut2 then guardarMensaje(parteEntrada[2]);
								if rut1 then guardarMensaje(parteEntrada[3]);
								guardarMensaje(': No existe el archivo o el directorio');
							end;
						end;
					end;
			end;
		end;
	end;
	
	
	// Recibe un array of strings en la variable clave y analiza que comando lanzar.
	// Si encontro el programa a lanzar, lo lanza y devuelve false, si no devuelve true.
	procedure Lanzador;
	var parte: string; 			
	begin
		parte:=parteEntrada[1];
		if (parte='mils') then lanzarMiLs
		else if (parte='micat') then lanzarMiCat
		else if (parte='micd') then
				begin
					if (length(parteEntrada)=2) and (parteEntrada[2]<>'') then MiCd (parteEntrada[2])
					else 
					begin
						writeln('Error en la cantidad de parametros');
						setlength(comandos,1);
						comandos[1]:='';
					end;
				end
		else if (parte='mipwd') then
				begin
					if (length(parteEntrada)=1) then MiPwd
					else guardarMensaje('Error en la cantidad de parametros');
				end
		else if (parte='mikill') then
				begin
					if (length(parteEntrada)=3) then MiKill(parteEntrada[2],parteEntrada[3])
					else guardarMensaje('Error en la cantidad de parametros');
				end
		else if (parte='mibg') then
				begin
					if (length(parteEntrada)=2) then MiBg (parteEntrada[2])
					else guardarMensaje('Error en la cantidad de parametros');
				end
		else if (parte='mifg') then
				begin
					if (length(parteEntrada)=2) then MiFg (parteEntrada[2])
					else guardarMensaje('Error en la cantidad de parametros');
				end;
    end;
	
end.
