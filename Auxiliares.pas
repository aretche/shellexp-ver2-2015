unit Auxiliares;

interface
	uses tipos, BaseUnix, Sysutils, Unix, crt;
	
	procedure Completar(var str:string;num:word);
	procedure guardarVector(info:ArrayChar); 	
	procedure guardarMensaje(str:string);
	procedure mostrar(var datos: ArrayChar);  
	 
    function verificarRuta(ruta:string): boolean;
 	function rutaPadre(ruta:string): string;
 	function verificarRutaArchivo(ruta:string): Boolean;
 	function devolverRutaArchivo(ruta:string): String;
 	function ConcatArray(vector1, vector2: ArrayChar): ArrayChar;
 	
	function abrirArchivo(arch:string): Longint; 
	procedure tratararchivo (archivoconc:string; var dato:ArrayChar);
	function GetFilePermissions(mode: mode_t): string;
	procedure escribirArchivo(arch:string;var datos: ArrayChar); 
	procedure reEscribirArchivo(arch:string;var datos: ArrayChar);
	
	procedure capturarTecla (pid:longint);
	function armarEntradaExterno:String;
		
implementation

	// Recibe un string y devuelve otro de longitud num, que posee el primero pero
	// que se completa con espacios (' ') hasta llegar al tamaño indicado
	// Si el string que se le pasa tiene una longitud mayor a num devuelve el mismo
	procedure Completar(var str:string;num:word);
	begin
		while length(str)<num do str:=str+' ';
	end;


	// Carga el mensaje de tipo ArrayChar que se le pasa en
	// la variable global dat del mismo tipo del shell
	procedure guardarVector(info:ArrayChar);
	var i,j:word;
	begin
		if High(dat)<1 then i:=1
		else i:=High(dat)+1;
		if i=1 then
	    begin
			SetLength(dat,i+1);
			//dat[i]:=#10;
			inc(i);
		end;
		j:=1;
		while (j <= High(info)) do
   	    begin
			SetLength(dat,i+1);
			dat[i]:=info[j];
			inc(i);
			inc(j);
	    end;
		SetLength(dat,High(dat)+2);
		dat[i]:=#10;
		dat[i+1]:=#13;
	end;


	// Carga el mensaje de tipo string que se le pasa en
	// la variable global dat de tipo ArrayChar del shell
	procedure guardarMensaje(str:string);
	var i,j:word;
	begin
		if High(dat)<1 then i:=1
		else i:=High(dat)+1;
		if i=1 then
		begin
			SetLength(dat,i+1);
			dat[i]:=#13;
			inc(i);
		end;
		for j:=1 to length(str) do
   	    begin
			SetLength(dat,i+1);
			dat[i]:=str[j];
			inc(i);
		end;
        SetLength(dat,High(dat)+2);
        dat[i]:=#10;
		dat[i+1]:=#13;
	end;
	
	 	
 	// Muestra en pantalla el contenido de la variable datos de tipo ArrayChar que se le pasa
    procedure mostrar(var datos: ArrayChar);   
	var  pos: word;
	begin
		if High(datos)>0 then
        begin
			for pos:= 1 to High(datos) do 
			begin
				Write(datos[pos]);
				datos[pos]:= #0;
			end;
	    end;
	    SetLength(datos,0);
	end;


	// Verifica que el string que se le pasa sea una ruta de directorio valida.
	function verificarRuta(ruta:string): boolean;
	begin
		{$I-}
        ChDir (ruta);
        if IOresult<>0 then verificarRuta:=false
		else verificarRuta:=true;
	end;


	// Recibe un string que posea '/' y devuelve otro en el cual ha eliminado el postfijo
	// que sigue a la ultima ocurrencia de '/'.
	function rutaPadre(ruta:string): string;
	begin
		while copy(ruta,length(ruta),length(ruta)) <> '/' do ruta:=copy(ruta,1,length(ruta)-1);
        if (length(ruta)=1) then rutaPadre:='/'
        else rutaPadre:=copy(ruta,1,length(ruta)-1);
	end;


	//Recibe la ruta de un archivo y verifica que el directorio sea valido
	function verificarRutaArchivo(ruta:string): Boolean;
	var rutaAux: String;
	begin
		if (copy(ruta,1,1) = '/') then rutaAux:= rutaPadre(ruta)
		else
		begin
            rutaAux:= directorio + '/' + ruta;
			rutaAux:= rutaPadre(rutaAux);
		end;
		verificarRutaArchivo:= verificarRuta(rutaAux);
	end;
	
	
	//Devuelve la ruta absoluta de un archivo
	function devolverRutaArchivo(ruta:string): String;
	var rutaAux: String;
	begin
		if (copy(ruta,1,1) = '/') then rutaAux:= ruta
		else
		begin
            rutaAux:= directorio + '/' + ruta;
		end;
		devolverRutaArchivo:= rutaAux;
	end;


	//Concatena dos vectores de tipo caracter
	function ConcatArray(vector1, vector2: ArrayChar): ArrayChar;
	var pos: Longint;
    begin
		SetLength(ConcatArray, Length(vector1) + Length(vector2));
		for pos := 0 to High(vector1) do ConcatArray[pos] := vector1[pos];
		for pos := 0 to High(vector2) do ConcatArray[pos + Length(vector1)] := vector2[pos];
    end;


	// abre el archivo de nombre arch para escritura y si no existe lo crea
	// devuelve el descriptor de archivo	
	function abrirArchivo(arch:string): Longint; 
	Var fd : Longint;			      						
	begin				
		fd := FPOpen(arch,O_WrOnly OR O_Creat);
		if fd > 0 then if FpFtruncate(fd,0)<>0 then Writeln ('Error con archivos!!!');	 	
	    abrirArchivo:=fd;
	end;
	

    //Abre el archivo y extrae su informacion para luego concatenarla, luego lo cierra.
	procedure tratararchivo (archivoconc:string; var dato:ArrayChar);
	var fd : Longint;
		cadena: string;
        pos: integer;
        arch: Stat;
	begin
		//obtiene información sobre el archivo y la almacena en arch. Devuelve cero si la llamada fue exitosa.
		if fpStat(archivoconc,arch)=0 then
		begin
			//se abre un archivo de sólo lectura, la función devuelve el descriptor de fichero, o un valor negativo si da error
			fd:= fpOpen(archivoconc,O_RdOnly);
			if (fd>0) then
			begin
				//establece la longitud de la cadena dato a el tamaño del archivo arch.
				SetLength(dato,arch.st_size+1);
				pos:=1;
				while (pos <> arch.st_size) do
					// Lee como maximo 1 bytes desde el descriptor de fichero fd, y los almacena en dato.
					// La función devuelve -1 si ocurre un error.
					if fpRead(fd,dato[pos],1) < 0 then 
					begin
					cadena:= archivoconc + ': Error leyendo archivo!!!';
					SetLength(dato,length(cadena)+1);
					guardarMensaje(cadena);
					pos:=arch.st_size;
					end
					else pos:=pos+1;
				//cierra un archivo con el descriptor de fichero fd.
				fpClose(fd);
			end
			else guardarMensaje(archivoconc + ': Error abriendo archivo!!!');
		end
		else guardarMensaje(archivoconc + ': No existe el archivo!!!');
    end;
	
	
	// Recibe un dato de tipo mode_t y devuelve un string que muestra
	// el tipo y los permisos del archivo para el usuario,el grupo y otros.
	function GetFilePermissions(mode: mode_t): string;
 	var Result: string;
 	begin
		Result:='';
		// file type
		if STAT_IFLNK and mode=STAT_IFLNK then Result:=Result+'l'
		else if STAT_IFDIR and mode=STAT_IFDIR then Result:=Result+'d'
		else if STAT_IFBLK and mode=STAT_IFBLK then Result:=Result+'b'
		else if STAT_IFCHR and mode=STAT_IFCHR then Result:=Result+'c'
		else Result:=Result+'-';
		// user permissions
		if STAT_IRUSR and mode=STAT_IRUsr then Result:=Result+'r'
		else Result:=Result+'-';
		if STAT_IWUsr and mode=STAT_IWUsr then Result:=Result+'w'
		else Result:=Result+'-';
		if STAT_IXUsr and mode=STAT_IXUsr then Result:=Result+'x'
		else Result:=Result+'-';
		// group permissions
		if STAT_IRGRP and mode=STAT_IRGRP then Result:=Result+'r'
		else Result:=Result+'-';
		if STAT_IWGRP and mode=STAT_IWGRP then Result:=Result+'w'
		else Result:=Result+'-';
		if STAT_IXGRP and mode=STAT_IXGRP then Result:=Result+'x'
		else Result:=Result+'-';
		// other permissions
		if STAT_IROTH and mode=STAT_IROTH then Result:=Result+'r'
		else Result:=Result+'-';
		if STAT_IWOTH and mode=STAT_IWOTH then Result:=Result+'w'
		else Result:=Result+'-';
		if STAT_IXOTH and mode=STAT_IXOTH then Result:=Result+'x'
		else Result:=Result+'-';
	    
	    GetFilePermissions:=Result;
	end;
	
	
	// guarda los datos que se le pasan en la variable datos de tipo ArrayChar
	// en el archivo de nombre arch. Si el archivo no existe lo crea
	// y si existe escribe los datos al final.
	procedure escribirArchivo(arch:string;var datos: ArrayChar); 
	Var fd : Longint;					      
		pos:word;						      
	begin
		fd := FPOpen(arch,O_WrOnly OR O_Creat);
        if fpLSeek(fd,0,Seek_end)=-1 then Writeln ('Error en el archivo!!!');
		if fd > 0 then
	    begin
			if High(datos)>0 then
				for pos:=1 to High(datos) do
					if (FPWrite(fd,datos[pos],1))=-1 then Writeln ('Error al escribir en el archivo!!!');
			FPClose(fd);
			SetLength(datos,0);
		end
		else Writeln ('Error al abrir el archivo!!!');
	end;
	
	
	// guarda los datos que se le pasan en la variable datos de tipo ArrayChar
	// en el archivo de nombre arch. Si el archivo no existe lo crea
	// y si existe lo sobreescribe.
	procedure reEscribirArchivo(arch:string;var datos: ArrayChar);
	Var fd : Longint;					       
		pos: word;						       
	begin
		//Abrir el archivo de sólo escritura o se crea el archivo si no existe. retorna el descriptor de archivo 
		fd := FPOpen(arch,O_WrOnly OR O_Creat);  
		if fd > 0 then                    
	    begin
			//Establece la longitud del archivo en fd en 0 bytes, la cantidad de bytes debe ser menor o igual a la  
			//longitud actual del archivo en fd. un valor de retorno distinto de cero indica que se produjo un error.
			if FpFtruncate(fd,0)<>0 then Writeln ('Error con archivos!!!');   
            if High(datos)>0 then        	
				for pos:=1 to High(datos) do 
					if (FPWrite(fd,datos[pos],1))=-1 then Writeln ('Error al escribir en el archivo!!!');
			//cierra el archivo.
			FPClose(fd);   
			SetLength(datos,0);
        end
        else Writeln ('Error al abrir el archivo!!!');
	end;
	
	
	//Cambia el valor de la variable para indicar que el 
	// proceso termino con la llegada de la senial SIGCHLD
	procedure finExterno(sig:longint);cdecl; 
	begin                    
		if (sig= 17) then terminaProc:=true;
	end;


	// Procedimiento que captura teclas del teclado 
	// desde el padre mientras corre un proceso hijo
	procedure capturarTecla (pid:longint); 
	var tecla:char;    
		
	begin	
		repeat			
			terminaProc:=false;	
			fpsignal(SIGCHLD,@finExterno);					
			while (keypressed) do
			begin	
			tecla:=Readkey;
			if (tecla= #26) then
			begin	
				if (Fpkill(pid,19)=0) then writeln('PID: ',pid,' se encuentra Detenido')
				else Writeln ('El proceso no pudo detenerse')	
			end;	
			end;		
		until (tecla= #26) or (terminaProc=true);	
	end;
	
	
	//Arma la instruccion para lanzar un comando externo desde el vector parteEntrada
	function ArmarEntradaExterno:String;
	var cadena: String;
		pos: integer;
	begin
		cadena:='';
		for pos:=1 to length(parteEntrada) do cadena:= cadena + parteEntrada[pos] + ' ';
		cadena:=copy(cadena,1,length(cadena)-1);
		ArmarEntradaExterno:= cadena;
	end;
end.
