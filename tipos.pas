unit tipos;
interface

	uses UnixType;

	type
        comando= array of string;
        ArrayChar= array of char;

	const
		meses: array[1..12] of string=('ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic');
        dias: array[1..31] of string=(' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31');
        numero: array[1..60] of string=('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60');

	var usuarioActual,hostActual ,olddir,home,homeMasUsuarioActual, directorio, entrada, operador:string;
		comandos, parteEntrada: array of String;
	    dat: ArrayChar;
        pid: longint;
	    idBg:TPid;
	    atras, frente: Text;
  	    hayRedireccion, terminaProc: boolean;

implementation

	Begin
	End.
