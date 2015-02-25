unit TDALista;

interface
	uses crt,BaseUnix,Auxiliares,tipos,Unix,Sysutils,dateutils, Users;

	type
		T_DATOL= record
			clave:string;
			nombre:string;
			color:byte;
			permisos:string;
			nlink:byte;
			usuario:string;
			grupo:string;
			tam:word;
			fecha:string;
		end;

        T_PUNTEROL= ^T_NODOL;

        T_NODOL= Record
			Info: T_DATOL;
            Siguiente: T_PUNTEROL;
		end;

        T_LISTA= Record
			Cabecera: T_PunteroL;
            Tamanio: Cardinal;
        end;

	// Crea una lista dinamica vacía y la devuelve en la variable L
    procedure CrearLista(var L:T_LISTA);
    //Inserta sin ordenar
    procedure insertar(var L:T_LISTA; x :T_DATOL);
    // Inserta ordenadamente el elemento que recibe en la variable x, en la lista L
    procedure InsertarOrdenado(var L:T_LISTA; x:T_DATOL);
    // Realiza un listado de los datos de la lista con el formato del comando ls -a
	procedure ListadoA(var L:T_LISTA);
	// Enlista los datos de la lista con el formato del comando ls -a y redirecciona la salida
	procedure ListadoAR(var L:T_LISTA);
	// Realiza un listado de los datos de la lista con el formato del comando ls sin parametro
	procedure Listado(var L:T_LISTA);
	// Enlista los datos de la lista con el formato del comando ls sin parametro y redirecciona la salida
	procedure ListadoR(var L:T_LISTA);
	// Realiza un listado de los datos de la lista con el formato del comando ls -f
	procedure ListadoF(var L:T_LISTA);
	// Enlista los datos de la lista con el formato del comando ls -f y redirecciona la salida
	procedure ListadoFR(var L:T_LISTA);
	// Realiza un listado de los datos de la lista con el formato del comando ls -l
	procedure ListadoL(var L:T_LISTA; var ttotal: word);
	// Enlista los datos de la lista con el formato del comando ls -l y redirecciona la salida
	procedure ListadoLR(var L:T_LISTA; var ttotal: word);
	procedure asignarL (var aux: T_DATOL; var archivo: STAT);
	Procedure asignarA (var lis: t_lista; var aux: T_DATOL; var archivo: STAT; dire: Pdir; par:String);


implementation

	procedure CrearLista(var L:T_LISTA);
	begin
		L.cabecera:=nil;
        L.tamanio:=0;
    end;


	procedure insertar(var L:T_LISTA; x :T_DATOL);
	var DirAux, ant, act: T_PUNTEROL;
	begin
		new(DirAux);
		DirAux^.Info := x;
		if (l.cabecera=nil) then 
		begin
			dirAux^.siguiente:= l.cabecera;
			l.cabecera:= dirAux;
		end
		else 
		begin
			Ant:=L.cabecera;
            Act:=L.cabecera^.siguiente;
            while (Act<>nil) do
            begin
				ant:=act;
                act:=act^.siguiente
            end;
            diraux^.siguiente:=act;
            ant^.siguiente:=diraux;
		end;
        Inc(L.tamanio);
	end;


    procedure InsertarOrdenado(var L:T_LISTA; x:T_DATOL);
    var Ant,Act,DirAux: T_PUNTEROL;
	begin
		new(DirAux);
        DirAux^.Info:=x;
        if (L.cabecera=nil) or (L.cabecera^.info.clave>x.clave) then
		begin
			DirAux^.siguiente:=L.cabecera;
			L.cabecera:=DirAux;
        end
		else
        begin
			Ant:=L.cabecera;
            Act:=L.cabecera^.siguiente;
            while (Act<>nil) and (Act^.info.clave<=x.clave) do
            begin
				ant:=act;
                act:=act^.siguiente
            end;
            diraux^.siguiente:=act;
            ant^.siguiente:=diraux;
		end;
        Inc(L.tamanio);
	end;


	procedure ListadoA(var L:T_LISTA);
    var Act: T_PUNTEROL;
	begin
		act:=L.cabecera;
		while (Act<>nil) do
		begin
			with Act^.info do
			begin
				textcolor(color);
				writeln(nombre);
			end;
			Act:=Act^.siguiente;
		end;
		textcolor(15);
	end;


	procedure ListadoAR(var L:T_LISTA);
    var Act: T_PUNTEROL;
    begin
		act:=L.cabecera;
        while (Act<>nil) do
        begin
			with Act^.info do guardarMensaje(nombre);
            Act:=Act^.siguiente;
        end;
        textcolor(15);
    end;


	procedure Listado(var L:T_LISTA);
    var Act: T_PUNTEROL;
	begin
		act:=L.cabecera;
		while (Act<>nil) do
		begin
			with Act^.info do
			begin
				if copy(nombre,1,1)<>'.' then
				begin
					textcolor(color);
					writeln(nombre);
				end
				else dec(L.tamanio);
			end;
			Act:=Act^.siguiente;
		end;
		textcolor(15);
	end;


	procedure ListadoR(var L:T_LISTA);
    var Act: T_PUNTEROL;
	begin
		act:=L.cabecera;
		while (Act<>nil) do
		begin
			with Act^.info do
			begin
				if copy(nombre,1,1)<>'.' then guardarMensaje(nombre)
				else dec(L.tamanio);
			end;
			Act:=Act^.siguiente;
		end;
		textcolor(15);
	end;


	procedure Listadof(var L:T_LISTA);
    var Act: T_PUNTEROL;
	begin
		act:=L.cabecera;
		while (Act<>nil) do
		begin
			with Act^.info do writeln(nombre);
			Act:=Act^.siguiente;
		end;
	end;


	procedure ListadoFR(var L:T_LISTA);
    var Act: T_PUNTEROL;
	begin
		act:=L.cabecera;
		while (Act<>nil) do
		begin
			with Act^.info do guardarMensaje(nombre);
			Act:=Act^.siguiente;
		end;
	end;


	procedure Listadol(var L:T_LISTA; var ttotal: word);
    var Act: T_PUNTEROL;
	begin
		act:=L.cabecera;
        while (Act<>nil) do
        begin
			with Act^.info do
		    begin
				if copy(nombre,1,1)<>'.' then
				begin
					textcolor(15);
					write(permisos);
					gotoxy(12,WhereY);
					write(nlink);
					gotoxy(14,WhereY);
					write(usuario);
					gotoxy(22,WhereY);
					write(grupo);
					gotoxy(30,WhereY);
					write(tam:7);
					gotoxy(38,WhereY);
					write(fecha);
					gotoxy(52,WhereY);
					textcolor(color);
					writeln(nombre);
					ttotal:=ttotal+tam;
				end
				else dec(L.tamanio);
			end;
            Act:=Act^.siguiente;
		end;
        textcolor(15);
	end;


	// Devuelve la cantidad de archivos y el tamaño total
	procedure ListadoLR(var L:T_LISTA; var ttotal:word);
    var Act: T_PUNTEROL;
		lin,aux:string;
    begin
		act:=L.cabecera;
		while (Act<>nil) do
        begin
			with Act^.info do
			begin
				if copy(nombre,1,1)<>'.' then
				begin
					lin:=permisos;
				    Completar(lin,12);
				    Str(nlink,aux);
				    lin:=lin+aux;
				    Completar(lin,14);
				    lin:=lin+usuario;
				    Completar(lin,22);
				    lin:=lin+grupo;
				    Completar(lin,30);
				    Str(tam,aux);
				    Completar(lin,37-length(aux));//para que el num quede alineado a la derecha
				    lin:=lin+aux;
				    Completar(lin,38);
				    lin:=lin+fecha;
				    Completar(lin,52);
				    lin:=lin+nombre;
				    guardarMensaje(lin);
				    ttotal:=ttotal+tam;
				end
				else dec(L.tamanio);
			end;
		Act:=Act^.siguiente;
        end;
	end;


	//Obtiene datos de archivo para el parametro -l del comando mils
	Procedure asignarL (var aux: T_DATOL; var archivo: STAT);
	var D:TDateTime;
		YY,MM,DD,HH,MI,SS,MS: word;
	begin
		aux.permisos:=GetFilePermissions(archivo.st_mode);  // permisos
		aux.nlink:=archivo.st_nlink;        				// links
	    aux.usuario:=GetUserName(archivo.st_uid);      		// usuario
		aux.grupo:=GetGroupName(archivo.st_gid);        	// grupo
		aux.tam:=archivo.st_size;        					// tamanio
		D:=UnixToDateTime(archivo.st_ctime);				// fecha de ultima modificacion
	    DecodeDate (D,YY,MM,DD) ;
	    DecodeTime (D,HH,MI, SS,MS) ;
	    aux.fecha:=(meses[MM]+' '+dias[DD]+' '+numero[HH]+':'+numero[MI]);
	end;


	//Obtiene datos de archivo para el parametro -a del comando mils
	Procedure asignarA (var lis: t_lista; var aux: T_DATOL; var archivo: STAT; dire: Pdir; par:String);
	var direcc: Pdirent;
	begin
		repeat
			direcc := fpReadDir(dire^);
			with direcc^ do
			begin
				if direcc <> nil then
				begin
					if fpLStat(pchar(@d_name[0]),archivo)=0  then
					begin
						//ejecutables {verde claro}
						if (not(fpS_ISDIR(archivo.st_mode))) and (STAT_IXUsr and archivo.st_mode=STAT_IXUsr) then aux.color:=10
						else if fpS_ISREG(archivo.st_mode) then aux.color:=15 	{blanco}
						else if fpS_ISLNK(archivo.st_mode) then aux.color:=11 	{celeste claro}
						else if fpS_ISDIR(archivo.st_mode) then aux.color:=9;	{azul claro}
						aux.clave:=upCase(pchar(direcc^.d_name));  		// clave
						aux.nombre:=pchar(direcc^.d_name);     			// nombre
						if par='-l' then asignarL(aux, archivo);
						insertarOrdenado (lis, aux);
					end;
				end;
			end;
		until direcc = nil;
	end;

end.
