unit funciones;

interface
	uses
	BaseUnix,Unix, TDALista,crt, SysUtils, UnixType,DateUtils,tipos,users,Auxiliares;
	
    procedure mipwd;
    procedure MiCd(ruta:string);
	procedure mikill(id_senal, id_proceso: string);
	procedure micat (arch1:string; arch2:string);
    procedure mils(parametro: String; ubicacion:string);
    procedure miBg(P1: string);
    procedure miFg(P1: string);
    procedure evaluarSalidaInterna;
    procedure lanzarExterno (cadena: String); 
	
implementation


	// Carga en la variable global dat un string con la ruta del directorio actual.
	procedure mipwd;
	begin guardarMensaje(directorio); end;


	// Cambia el valor de la variable global directorio (directorio de trabajo actual) segun el string que se le pasa
	procedure MiCd(ruta:string);
	begin
		if (ruta='~') then ruta:=homeMasUsuarioActual
		else if (ruta='.') then ruta:=directorio
		else if (ruta='..') then ruta:=rutaPadre(directorio)
		else if (ruta='-') then ruta:=olddir
		//CUANDO EMPIEZA CON / NO SE HACE NADA PORQUE LA RUTA QUEDA ASI NOMAS
		else if (copy(ruta,1,1) <> '/') then ruta:=directorio+'/'+ruta;
		
		if verificarRuta(ruta) then
		begin
			olddir:=directorio;
			directorio:=ruta;
		end
		else
		begin
			guardarMensaje('Error ');
			guardarMensaje(ruta);
			guardarMensaje(': No existe el archivo o el directorio');
		end;
		mipwd;
	end;
	
	
	// Envia la señal al proceso
	procedure mikill(id_senal, id_proceso: string);
	var num_proceso, num_senal, res1, res2: word;
	begin
		//convierte el String a numero
		val(id_proceso,num_proceso,res1);
		val(id_senal,num_senal,res2);
		//Comprueba que la conversion de string a integer haya sido valida
	    if (res1 = 0) and (res2 = 0) then 
	    begin
			if (Fpkill(num_proceso,num_senal)=0) then 
			    guardarMensaje('El proceso: ' + id_proceso + ' recibió la señal: ' + id_senal)
			else guardarMensaje('El proceso: ' + id_proceso + ' no existe o no soporta la señal: ' + id_senal);
		end
	    else guardarMensaje('El proceso necesita 2 parametros numericos: señal - pid del proceso ');
	end;
	
	
	//Procedimiento que concatena archivos, pueden ser uno, dos o ningun archivo
	//Si es uno muestra ese archivo, si no hay ninguno muestra la entrada estandar que se ingrese
	procedure micat (arch1:string; arch2:string);
	var a: char;
		datos,info: ArrayChar;
		i: word;
		
	begin
		datos:=dat;
		SetLength(dat,0);
		SetLength(info,0);
		//Se ejecuta este bloque cuando no se le pasa ningun archivo para concatenar
		if (arch1 = '<>') and (arch2 = '<>') then
		begin
			if High(datos)<1 then i:=1
			else i:=High(datos)+1;
			a:=readkey;
			while a<>#13 do
			begin
				write(a);
				SetLength(datos,i+1);
				datos[i]:=a;
				inc(i);
				a:=readkey;
			end;
			guardarVector(datos);
		end
		else
		begin
			//Se ejecuta este bloque cuando se le pasa solo un archivo para concatenar
			if (arch1 <> '<>') and (arch2 = '<>') then
			begin
				tratararchivo (devolverRutaArchivo(arch1), info);
				datos:=ConcatArray(datos,info);
				guardarVector(datos);
			end
			else
			begin
				//Se ejecuta este bloque cuando se le pasan dos archivo para concatenar
				if (arch1 <> '<>') and (arch2 <> '<>') then
				begin
					tratararchivo (devolverRutaArchivo(arch1), info);
					info:=ConcatArray(datos,info);
					tratararchivo (devolverRutaArchivo(arch2), datos);
					info:=ConcatArray(info,datos);
					guardarVector(info);
				end;
			end;
        end;
	end;
	
	
	// Realiza el comando ls analizando el parametro de entrada (si lo hay)
	// y muestra en pantalla (si no hay redireccion) o lo guarda en un vector (si hay redireccion)
	procedure mils(parametro: String; ubicacion:string);
	var dire: Pdir;
		direcc: Pdirent;
		archivo: stat;
		ttotal : word ;
		aux: T_DATOL;
		lis: T_LISTA;
        ubi, cant_total:string;
                
	begin
		ubi:=ubicacion;
	    ttotal:=0;
	    crearlista(lis);
	    if (ubicacion <> '<>') then micd(ubicacion)
	    else micd (directorio);
	    ubicacion:=directorio;
	    dire:= fpOpenDir(ubicacion);
	    if dire<>nil then
	    begin
			if (parametro = '-a') or (parametro = '<>') or (parametro = '-l') then 
				asignarA (lis, aux, archivo, dire, parametro);
			if (parametro = '-f') then
			begin
				repeat
					direcc := fpReadDir(dire^);
					with direcc^ do
					begin
						if direcc <> nil then
						begin
							if fpLStat(pchar(@d_name[0]),archivo)=0  then
							begin
								aux.nombre:=pchar(direcc^.d_name);  // nombre
								Insertar(lis,aux);
							end;
						end;
					end;
				until direcc = nil;
			end;
			if not(hayRedireccion) then
			begin
				if (parametro = '-l') then
				begin
					listadoL(lis, ttotal);
					writeln('Total: ',ttotal { div 1024});
				end;
				if (parametro = '-a') then listadoA(lis);
				if (parametro = '<>') then listado (lis);
				if (parametro = '-f') then listadoF(lis);
				writeln('Cantidad de archivos: ',lis.tamanio);
				fpCloseDir (dire^);
			end
			else
			begin
				if (parametro = '-l') then
				begin
					listadoLR(lis, ttotal);
					str(ttotal,cant_total);
					guardarMensaje ('Total: ');
					guardarMensaje (cant_total); { div 1024}
				end;
				if (parametro = '-a') then listadoAR(lis);
				if (parametro = '<>') then listadoR (lis);
				if (parametro = '-f') then listadoFR(lis);
				str(lis.tamanio,cant_total);
				guardarMensaje('Cantidad de archivos: ');
				guardarMensaje(cant_total);
				fpCloseDir (dire^);
			end;
		end
		else
		begin
			if not(hayRedireccion) then Write('Error en la lectura del directorio')
			else guardarMensaje ('Error en la lectura del directorio');
		end;
	    if ubi<> '<>' then micd('-');
	end;
	
	
	// Recibe el pid de un proceso en P1, si es un pid valido lo guarda y ejecuta el proceso en 2ndo plano
	procedure miBg(P1: string);      
	var	senialResumir: cint;
		cod: word;
		pid: longint;
	begin
		val(P1,pid,cod);
		idBg:=pid;
		senialResumir:=SIGCONT;
		if (pid<>-1) then
		begin
			if (cod = 0) then  	   	
				If (Fpkill(pid,senialResumir) =0) then writeln('PID: ',pid,' se encuentra ejecuta en 2do Plano')
				else writeln('El PID es incorrecto o el proceso no soporta la senial');
		end
		else writeln('El PID debe ser un valor numerico');
	end;
	
	
	// Recibe el pid de un proceso en P1, si es un pid valido le envia la señal de Resumen
	// Si no recibe un pid (recibe -1) entonces envia la señal al ultimo proceso que fue pausado
	procedure miFg(P1: string);	
	var senialResumen: cint;
	    cod: word;
	    pid: longint;
	begin
	val(P1,pid,cod);
	senialResumen:=SIGCONT;       
   	if (pid<>-1) then
		begin
		if (cod = 0) then
			If (Fpkill(pid,senialResumen)=0)then
			begin
				writeln('PID: ',pid,' se encuentra corriendo en 1er Plano');
				capturarTecla(pid);
			end
			else writeln('El PID es incorrecto o el proceso no soporta la senial');
        end     
		else
		begin
			Fpkill(idBg,senialResumen);
			writeln('PID: ',idBg,' se encuentra corriendo en 1er Plano');
			capturarTecla(pid);
        end;
	end;

	
	procedure evaluarSalidaInterna;
	var cadena: String;
		pos:integer;
	begin
		if (operador = '>') then
		begin
			if (length(parteEntrada)=1) then 
			begin
				parteEntrada[1]:= devolverRutaArchivo(parteEntrada[1]);
				if (verificarRutaArchivo(parteEntrada[1])) then 
				begin
					reEscribirArchivo(parteEntrada[1],dat);
					writeln ('La salida se redireccionó con exito');
				end	
				else writeln ('La ruta o nombre de archivo ingresada es invalida');
			end
			else writeln ('Error en la cantidad de parametros');
		end;
		if (operador = '>>') then
		begin
			if (length(parteEntrada)=1)then 
			begin
				parteEntrada[1]:= devolverRutaArchivo(parteEntrada[1]);
				if (verificarRutaArchivo(parteEntrada[1])) then 
				begin
					escribirArchivo(parteEntrada[1],dat);
					writeln ('La salida se redireccionó con exito');
				end
				else writeln ('La ruta o nombre de archivo ingresada es invalida');
			end
			else writeln ('Error en la cantidad de parametros');
		end;
		if (operador = '|') then
		begin
			cadena:='';
			for pos:=1 to length(dat)-2 do cadena:= cadena + dat[pos];
			setlength(parteEntrada, length(parteentrada));
			parteEntrada[length(parteEntrada)+1]:= cadena;
		end;
		setlength(comandos,1);
		comandos[1]:='';
	end;


	// Lanza un programa externo que se le pasa como string,
	// enviandole datos en el archivo tuberia.txt.
	// Además cierra la salida estandar (1) y la salida de error estandar (2)
	// y abre dos archivos ('salida.txt' y 'errores.txt') para que reciban esos datos.
	procedure lanzarExterno (cadena: String); 
	var	programa: string;
		PP: PPchar;    //Puntero a un array de punteros a cadenas terminadas en nulo.   
	begin
		programa:='cd ' + directorio + '; '+ cadena;    
		//Crear un array terminado en cero de las cadenas de una cadena de línea de comandos
		PP:=CreateShellArgV(programa);
        programa:=PP[0];   
        //reemplaza el programa en curso con el programa que se especifica en programa.
        //El ejecutable se busca en la ruta de acceso, si no es un nombre de archivo absoluto.
        //Se le da al programa las opciones en PP. Esto es un puntero a un array de punteros a cadenas 
        //terminadas en nulo. El último puntero debe ser nulo y El entorno actual se pasa al programa. 
        fpExecvp(programa, PP);  
	end;                    	
                                
end.
                                
	
