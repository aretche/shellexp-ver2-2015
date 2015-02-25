unit redireccionObjeto;

//Se hace el procedimiento de redireccion en una unit a parte 
//porque implementa el modo pascal Object y no pudimos lograr que ande junto
// con las units procedurales

INTERFACE 
	
	//Indica a pascal que funcionará en modo objeto.
	{$mode objfpc}
	
	uses Sysutils, baseunix, funciones;
 
	procedure redireccionarSalida (Entrada, nombreArchivo :String);
	procedure tuberia (Entrada1, Entrada2, nombreArchivo: String);

IMPLEMENTATION

	function leerSalida (nombreArchivo:string):String;
	var fd : Longint;
		cadena: string;
        pos: integer;
        arch: Stat;
	begin
		cadena:='';
		//obtiene información sobre el archivo y la almacena en arch. Devuelve cero si la llamada fue exitosa.
		if fpStat(nombreArchivo,arch)=0 then
		begin
			//se abre un archivo de sólo lectura, la función devuelve el descriptor de fichero, o un valor negativo si da error
			fd:= fpOpen(nombreArchivo,O_RdOnly);
			if (fd>0) then
			begin
				//Obtiene la lectura de todo el archivo.
				pos:=1;
				while (pos <> arch.st_size) do
					// Lee como maximo 1 bytes desde el descriptor de fichero fd, y los almacena en dato.
					// La función devuelve -1 si ocurre un error.
					if fpRead(fd,cadena[pos],1) < 0 then writeln (nombreArchivo + ': Error leyendo archivo!!!')
					else pos:=pos+1;
				//cierra un archivo con el descriptor de fichero fd.
				fpClose(fd);
			end
			else writeln(nombreArchivo + ': Error abriendo archivo!!!');
		end
		else writeln(nombreArchivo + ': No existe el archivo!!!');
		leerSalida:=cadena;
    end;


	//Realiza una tuberia tomando la salida estandar del primer comando
	//y convirtiendola en la entrada estandar del segundo comando
	procedure tuberia (Entrada1, Entrada2, nombreArchivo: String);
	var	archSalida : ^File;
		apSalida : longint;
	begin
		//Crea un puntero a archivo
		New(archSalida);
		//Asigna el puntero a un archivo con nombre.
		Assign (archSalida^, nombreArchivo);
		//Re-escribe en el puntero
		Rewrite(archSalida^);
		Reset(archSalida^);
		//Se obtiene el identificador de la salida estandar y se le hace un duplicado
		apSalida:=fpdup(StdInputHandle);
		//FileRec se utiliza para la representación interna de tipeo y archivos sin tipo.
		//El apuntador del archivo de salida apunta al apuntador de la salida estandar
		fpdup2(FileRec(archSalida^).Handle,StdInputHandle);
		//Writeln
		lanzarExterno(Entrada1);
		//vuelve a dejar el apuntador de la salida estandar donde estaba
		fpdup2(apSalida,StdInputHandle);
		//Cierra el apuntador al archivo de salida estandar
		Close(archSalida^);
		//Cierra el apuntador al archivo de entrada estandar
		fpclose(apSalida);
		Entrada1:= leerSalida(nombreArchivo);
		Entrada2:= Entrada2 + ' ' + Entrada1;
		lanzarExterno(Entrada2);
		DeleteFile(nombreArchivo);
	end;
	

	//Realiza la redireccion de salida estandar para comandos externos
	procedure redireccionarSalida (Entrada, nombreArchivo :String);
	var archSalida : ^File;
		apSalida : longint;
	begin
		//Crea un puntero a archivo
		New(archSalida);
		//Asigna el puntero a un archivo con nombre.
		Assign (archSalida^, nombreArchivo);
		//Re-escribe en el puntero
		Rewrite(archSalida^);
		//Se obtiene el identificador de la salida estandar y se le hace un duplicado
		apSalida:=fpdup(StdOutputHandle);
		//FileRec se utiliza para la representación interna de tipeo y archivos sin tipo.
		//El apuntador del archivo de salida apunta al apuntador de la salida estandar
		fpdup2(FileRec(archSalida^).Handle,StdOutputHandle);
		//Writeln
		lanzarExterno(Entrada);
		//vuelve a dejar el apuntador de la salida estandar donde estaba
		fpdup2(apSalida,StdOutputHandle);
		//Cierra el apuntador al archivo de salida estandar
		Close(archSalida^);
		//Cierra el apuntador al archivo de entrada estandar
		fpclose(apSalida);
	end;
	
end.

	
