program programa;

uses crt, BaseUnix, Unix, Inicializadores, tipos, Auxiliares, funciones, redireccionObjeto;

var Entrada1, Entrada2: String;

begin
	iniciarvariables;
	repeat
		prompt;
		inicializarValores;
		readln(Entrada);
		comandos:=Descifrador(Entrada);
		if (comandos[1] <>'exit') then
		begin
			hayRedireccion:=multipleEntrada;
			while (comandos[1]<>'') do
			begin
				parteEntrada:= (obtenerEntrada);
				if (esInterno) and (not hayRedireccion) then lanzador
				else if (esInterno) and (hayRedireccion) then 
					 begin
						lanzador;
						setlength(parteEntrada,0);
						parteEntrada:= (obtenerEntrada);
						if (obtenerOperador='|') and (not esInterno) then 
							Writeln('Debe ingresar dos comandos internos o dos externos')
						else 
						begin
							evaluarSalidaInterna;
							if (operador='|') then lanzador;
						end;
					end
				else //No es interno
				begin
					pid := fpFork;
					case pid of
						-1 : Writeln('Error en el Sistema!!!');
						 0 : begin
								if (hayRedireccion) and (obtenerOperador='|') then
								begin
									Entrada1:= ArmarEntradaExterno;
									parteEntrada:= (obtenerEntrada);
									Entrada2:= ArmarEntradaExterno;
									tuberia(Entrada1, Entrada2, 'tub.txt');
								end
								else if (hayRedireccion) and ((obtenerOperador='>') or (obtenerOperador='>>'))  then
								begin
									Entrada:= ArmarEntradaExterno;
									parteEntrada:= (obtenerEntrada);
									//lanza el comando externo dentro de la redireccion
									redireccionarSalida(Entrada, parteEntrada[1]);
								 end
								 else lanzarExterno(Entrada); //No hay redireccion
							 end;
							else begin capturarTecla(pid); end;
					end;
				end;
			end;
			setlength(parteEntrada,1);
			if 	((hayRedireccion) and (operador='|')) or 
				((not(hayRedireccion)) and (parteEntrada[1]<>'mils')) then mostrar(dat);
		end;
	until (comandos[1]='exit');	
	Writeln('Hasta luego... ¡Gracias por usar nuestro shell!');
end.
