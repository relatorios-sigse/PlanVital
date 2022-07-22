SELECT 
/**
Modificaciones,
06-11-2020. Andrés Del Río. Inclusión de primera línea con valor 'Formulario Informacion de Transaccion' en la columna Razón social.
10-11-2020. Andrés Del Río. Deshacer cambio realizado el 06-11-2020.
11-11-2020. Andrés Del Río. Ajuste en campo calculado Operación (basado en campo TRAN_compraventa) debe mostrar Compra/Venta, pero en  mayúsculas.
11-11-2020. Andrés Del Río. Inclusión de campo apellidos_nombres que concatena los nombres y apellidos invertidos reordenados (dejando primero los apellidos y luego los nombres), usando fórmula de botón SEPARAR NOMBRES del formulario de antecedentes.
El ajuste solo aplica cuando la transacción fue realizada por la PERSONA SUJETA o el CONYUGE. Cuando la transacción fue realizada por SOCIEDAD, no se hace el reordenamiento del nombre.
19-11-2020. Andrés Del Río. Reemplazar los campos Precio Unitario y Valor Total de la grid de transacciones.
preciounitario2 -> preciounitario3
valortotal2 -> valortotal3
03-06-2021. Andrés Del Río. Incidente. Cliente reporta que la transacción con wf 001413 no estaba trayendo la razón social (campo apellidos_nombre).
Causa: habían dos espacios, en vez de uno, en el campo GRID.nombrefinal, el cual es usado para extraer los apellidos y nombres y luego para mostrar
el nombre en formato APELLIDOS NOMBRES. Solución: se reemplazaron las ocurrencias de dos o más espacios seguidos por uno solo, cambiando GRID.nombrefinal por
trim(regexp_replace(GRID.nombrefinal, '\s+', ' ', 'g')) TRAN_nombrefinal.
22-07-2021. Andrés Del Río. Incidente. Cliente reporta que nombre FEDERICO MARIA MOROSI está siendo mostrado en reporte como
MARIA MOROSI FEDERICO, cuando debería ser MOROSI FEDERICO MARIA. Para resolverlo, se consulta los datos de los antecedentes, en donde el nombre, apellido paterno
y apellido materno están ya separados
22-07-2022. Andrés Del Río. Incidente. Cliente reporta que las transacciones de RODRIGO CRISOSTOMO están duplicadas.
Cuando el usuario tiene más de una alta (debido a un cambio de área), la query hacía el distinct de los registros. Además, uno de los apellidos
de este usuario en una de las altas aparece con Ñ y en otra con N, evitando que el DISTINCT incluído para resolver la situación no sea suficiente.
**/
CASE  WHEN TMP.TRAN_usuariotransaccion = 'SOCIEDAD' OR TMP.TRAN_usuariotransaccion = 'CONYUGE' THEN TRAN_nombrefinal ELSE  CASE WHEN NOMBAPELL.APELLIDO_MATERNO <> '' THEN NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.APELLIDO_MATERNO || ' ' || NOMBAPELL.NOMBRE ELSE NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.NOMBRE END END APELLIDOS_NOMBRES,
TMP.* 
FROM (
SELECT
        IDPROCESS,
        NMPROCESS,
        NMPROCESSMODEL,
        NMOCCURRENCETYPE,
        IDSLASTATUS,
        IDLEVEL,
        NMDEADLINE,
        DTSTART,
        IDSITUATION,
        NMEVALRESULT,
        NMUSERSTART,
        TYPEUSER,
        IDREVISIONSTATUS,
        NMREVISIONSTATUS,
        DTDEADLINEFIELD,
        NMACTTYPE,
        IDREVISION,
        DTFINISH,
        DTSLAFINISH,
        TABLE0__ADJUNTARANEXOB_1,
        TABLE0__APELLIDOM_1,
        TABLE0__APELLIDOMCONYUG_1,
        TABLE0__APELLIDOP_1,
        TABLE0__APELLIDOPCONYUG_1,
        TABLE0__AREA_1,
        TABLE0__CARGO_1,
        TABLE0__CASADO_3,
        TABLE0__COMENTARIOSVERI_2,
        TABLE0__CORREO_1,
        TABLE0__CDUSER_1,
        TABLE0__DOMICILIO_1,
        TABLE0__FECHACAPACITACI_6,
        TABLE0__FECHAEJECUCION_6,
        TABLE0__FECHAINGRESO_6,
        TABLE0__FECHAMATRIMONIO_6,
        TABLE0__FECHATERMINO_6,
        TABLE0__FECHAPLAZO_6,
        TABLE0__FECHAREG_6,
        TABLE0__HORA_5,
        TABLE0__IDAREA_1,
        TABLE0__IDCARGO_1,
        TABLE0__IDENTIFICADOR_1,
        TABLE0__IDPRINCIPAL_1,
        TABLE0__IDTEAM_1,
        TABLE0__LOGI_1,
        TABLE0__LUGAR_1,
        TABLE0__NOMBRECOMPLETO_1,
        TABLE0__NOMBRES_1,
        TABLE0__NOMBRECONYUGE_1,
        TABLE0__NREG_1,
        TABLE0__NPASAPORTE_1,
        TABLE0__PASAPORTECONYUG_1,
        TABLE0__RDBRUT_3,
        TABLE0__RDBRUTCONYUGE_3,
        TABLE0__REGISTROEXISTEN_1,
        TABLE0__RESALG_1,
        TABLE0__RESULTADOWS_11,
        TABLE0__RESULTADOQUERY_2,
        TABLE0__RUT_1,
        TABLE0__RUTCONYUGE_1,
        TABLE0__TELEFONO_1,
        TABLE0__TEMPORAL_1,
        TABLE0_REF0_CARGO_1,
        TABLE0_REF1_TIPOACCION_1,
        TABLE0_REF2_PERSONA_1,
        TABLE0_REF2_IDPERSONA_1,
        TRAN_nombrefinal,


/**  
case
when length(TRAN_nombrefinal) - length(replace(TRAN_nombrefinal, ' ', '')) = 1 then (SELECT SPLIT_PART(TRAN_nombrefinal,' ', 1))
when length(TRAN_nombrefinal) - length(replace(TRAN_nombrefinal, ' ', '')) = 2 then (SELECT SPLIT_PART(TRAN_nombrefinal,' ', 1))
when length(TRAN_nombrefinal) - length(replace(TRAN_nombrefinal, ' ', '')) = 3 then (SELECT SPLIT_PART(TRAN_nombrefinal,' ', 1) || ' ' || SPLIT_PART(TRAN_nombrefinal,' ', 2)) end nombre,
case
when length(TRAN_nombrefinal) - length(replace(TRAN_nombrefinal, ' ', '')) = 1 then (SELECT SPLIT_PART(TRAN_nombrefinal,' ', 2))
when length(TRAN_nombrefinal) - length(replace(TRAN_nombrefinal, ' ', '')) = 2 then (SELECT SPLIT_PART(TRAN_nombrefinal,' ', 2))
when length(TRAN_nombrefinal) - length(replace(TRAN_nombrefinal, ' ', '')) = 3 then (SELECT SPLIT_PART(TRAN_nombrefinal,' ', 3)) end apellido_paterno,
case
when length(TRAN_nombrefinal) - length(replace(TRAN_nombrefinal, ' ', '')) = 1 then ''
when length(TRAN_nombrefinal) - length(replace(TRAN_nombrefinal, ' ', '')) = 2 then (SELECT SPLIT_PART(TRAN_nombrefinal,' ', 3))
when length(TRAN_nombrefinal) - length(replace(TRAN_nombrefinal, ' ', '')) = 3 then (SELECT SPLIT_PART(TRAN_nombrefinal,' ', 4)) end apellido_materno, 
**/     
CASE WHEN TRAN_pasaportefinal IS NULL THEN TRIM(TRAN_rutfinal) ELSE TRIM(TRAN_pasaportefinal) END IDENTIFICADOR,

        TRAN_rutfinal,
        TRAN_pasaportefinal,
        TRAN_fechatransaccio,
        TRAN_foliotransaccio,
        TRAN_fechaperfeccion,
        TRAN_rutemisor,
        TRAN_nombreemisor,
        TRAN_serie,
        TRAN_nemotecnico,
        TRAN_unidades,
        TRAN_moneda2,
        TRAN_preciounitario3,
        TRAN_valortotal3,
        TRAN_compraventa,
        TRAN_intermediario,
        TRAN_tir,
        TRAN_codigotransac,
        TRAN_cargo,
        TRAN_tipoinstrumento,
        TRAN_usuariotransaccion,
        '2' orden
    FROM
        (SELECT
            IDPROCESS,
            NMPROCESS,
            NMPROCESSMODEL,
            NMOCCURRENCETYPE,
            IDSLASTATUS,
            IDLEVEL,
            NMDEADLINE,
            DTSTART,
            IDSITUATION,
            NMEVALRESULT,
            NMUSERSTART,
            TYPEUSER,
            IDREVISIONSTATUS,
            NMREVISIONSTATUS,
            DTDEADLINEFIELD,
            NMACTTYPE,
            IDREVISION,
            DTFINISH,
            DTSLAFINISH,
            TABLE0__ADJUNTARANEXOB_1,
            TABLE0__APELLIDOM_1,
            TABLE0__APELLIDOMCONYUG_1,
            TABLE0__APELLIDOP_1,
            TABLE0__APELLIDOPCONYUG_1,
            TABLE0__AREA_1,
            TABLE0__CARGO_1,
            TABLE0__CASADO_3,
            TABLE0__COMENTARIOSVERI_2,
            TABLE0__CORREO_1,
            TABLE0__CDUSER_1,
            TABLE0__DOMICILIO_1,
            TABLE0__FECHACAPACITACI_6,
            TABLE0__FECHAEJECUCION_6,
            TABLE0__FECHAINGRESO_6,
            TABLE0__FECHAMATRIMONIO_6,
            TABLE0__FECHATERMINO_6,
            TABLE0__FECHAPLAZO_6,
            TABLE0__FECHAREG_6,
            TABLE0__HORA_5,
            TABLE0__IDAREA_1,
            TABLE0__IDCARGO_1,
            TABLE0__IDENTIFICADOR_1,
            TABLE0__IDPRINCIPAL_1,
            TABLE0__IDTEAM_1,
            TABLE0__LOGI_1,
            TABLE0__LUGAR_1,
            TABLE0__NOMBRECOMPLETO_1,
            TABLE0__NOMBRES_1,
            TABLE0__NOMBRECONYUGE_1,
            TABLE0__NREG_1,
            TABLE0__NPASAPORTE_1,
            TABLE0__PASAPORTECONYUG_1,
            TABLE0__RDBRUT_3,
            TABLE0__RDBRUTCONYUGE_3,
            TABLE0__REGISTROEXISTEN_1,
            TABLE0__RESALG_1,
            TABLE0__RESULTADOWS_11,
            TABLE0__RESULTADOQUERY_2,
            TABLE0__RUT_1,
            TABLE0__RUTCONYUGE_1,
            TABLE0__TELEFONO_1,
            TABLE0__TEMPORAL_1,
            TABLE0_REF0_CARGO_1,
            TABLE0_REF1_TIPOACCION_1,
            TABLE0_REF2_PERSONA_1,
            TABLE0_REF2_IDPERSONA_1,
            TRAN_nombrefinal,
            TRAN_rutfinal,
            TRAN_pasaportefinal,
            TRAN_fechatransaccio,
            TRAN_foliotransaccio,
            TRAN_fechaperfeccion,
            TRAN_rutemisor,
            TRAN_nombreemisor,
            TRAN_serie,
            TRAN_nemotecnico,
            TRAN_unidades,
            TRAN_moneda2,
            TRAN_preciounitario3,
            TRAN_valortotal3,
            TRAN_compraventa,
            TRAN_intermediario,
            TRAN_tir,
            TRAN_codigotransac,
            TRAN_cargo,
            TRAN_tipoinstrumento,
            TRAN_usuariotransaccion
        FROM
            (SELECT
                1 AS QTD,
                WFP.IDPROCESS,
                WFP.NMPROCESS,
                WFP.NMPROCESSMODEL,
                COALESCE(ADU.NMUSER,
                TBEXT.NMUSER) AS NMUSERSTART,
                CASE 
                    WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN '#{303826}' 
                    WHEN WFP.CDUSERSTART IS NOT NULL THEN '#{305843}' 
                    ELSE NULL 
                END AS TYPEUSER,
                GNT.NMGENTYPE AS NMOCCURRENCETYPE,
                GNRS.IDREVISIONSTATUS,
                GNRS.NMREVISIONSTATUS,
                CASE 
                    WHEN WFP.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE 
                        WHEN WFP.FGCONCLUDEDSTATUS=1 THEN '#{100900}' 
                        WHEN WFP.FGCONCLUDEDSTATUS=2 THEN '#{100899}' 
                    END) 
                    ELSE (CASE 
                        WHEN (( WFP.DTESTIMATEDFINISH > (CAST(<!%TODAY%> AS DATE) + COALESCE((SELECT
                            QTDAYS 
                        FROM
                            ADMAILTASKEXEC 
                        WHERE
                            CDMAILTASKEXEC=(SELECT
                                TASK.CDAHEAD 
                            FROM
                                ADMAILTASKREL TASK 
                            WHERE
                                TASK.CDMAILTASKREL=(SELECT
                                    TBL.CDMAILTASKSETTINGS 
                                FROM
                                    CONOTIFICATION TBL))), 0))) 
                        OR (WFP.DTESTIMATEDFINISH IS NULL)) THEN '#{100900}' 
                        WHEN (( WFP.DTESTIMATEDFINISH=CAST( cast(now() as date) AS DATE) 
                        AND WFP.NRTIMEESTFINISH >= (extract('minute' 
                    FROM
                        now()) + extract('hour' 
                    FROM
                        now()) * 60)) 
                        OR (WFP.DTESTIMATEDFINISH > CAST( cast(now() as date) AS DATE))) THEN '#{201639}' 
                        ELSE '#{100899}' 
                    END) 
                END AS NMDEADLINE,
                CASE WFP.FGSLASTATUS 
                    WHEN 10 THEN '#{218492}' 
                    WHEN 30 THEN '#{218493}' 
                    WHEN 40 THEN '#{218494}' 
                END AS IDSLASTATUS,
                CASE WFP.FGSTATUS 
                    WHEN 1 THEN '#{103131}' 
                    WHEN 2 THEN '#{107788}' 
                    WHEN 3 THEN '#{104230}' 
                    WHEN 4 THEN '#{100667}' 
                    WHEN 5 THEN '#{200712}' 
                END AS IDSITUATION,
                GNR.NMEVALRESULT,
                (SELECT
                    MAX(IDLEVEL) 
                FROM
                    GNSLACTRLHISTORY 
                WHERE
                    CDSLACONTROL=WFP.CDSLACONTROL 
                    AND FGCURRENT=1) AS IDLEVEL,
                PT.NMACTTYPE,
                GNREV.IDREVISION,
                CAST(CAST('1970-01-01' AS DATE) + (CAST(SLACTRL.BNSLAFINISH AS BIGINT) / 1000)/60 * interval '1 minute' || ' -05:00' AS timestamptz) AS DTSLAFINISH,
                WFP.DTESTIMATEDFINISH + (WFP.NRTIMEESTFINISH * interval '1 minute') AS DTDEADLINEFIELD,
                TO_TIMESTAMP(TO_CHAR(WFP.DTSTART,
                'YYYY-MM-DD') || ' ' || WFP.TMSTART,
                'YYYY-MM-DD HH24:MI:SS') AS DTSTART,
                TO_TIMESTAMP(TO_CHAR(WFP.DTFINISH,
                'YYYY-MM-DD') || ' ' || WFP.TMFINISH,
                'YYYY-MM-DD HH24:MI:SS') AS DTFINISH,
                TABLE0_OUTER.TABLE0__ADJUNTARANEXOB_1,
                TABLE0_OUTER.TABLE0__APELLIDOM_1,
                TABLE0_OUTER.TABLE0__APELLIDOMCONYUG_1,
                TABLE0_OUTER.TABLE0__APELLIDOP_1,
                TABLE0_OUTER.TABLE0__APELLIDOPCONYUG_1,
                TABLE0_OUTER.TABLE0__AREA_1,
                TABLE0_OUTER.TABLE0__CARGO_1,
                TABLE0_OUTER.TABLE0__CASADO_3,
                TABLE0_OUTER.TABLE0__COMENTARIOSVERI_2,
                TABLE0_OUTER.TABLE0__CORREO_1,
                TABLE0_OUTER.TABLE0__CDUSER_1,
                TABLE0_OUTER.TABLE0__DOMICILIO_1,
                TABLE0_OUTER.TABLE0__FECHACAPACITACI_6,
                TABLE0_OUTER.TABLE0__FECHAEJECUCION_6,
                TABLE0_OUTER.TABLE0__FECHAINGRESO_6,
                TABLE0_OUTER.TABLE0__FECHAMATRIMONIO_6,
                TABLE0_OUTER.TABLE0__FECHATERMINO_6,
                TABLE0_OUTER.TABLE0__FECHAPLAZO_6,
                TABLE0_OUTER.TABLE0__FECHAREG_6,
                TABLE0_OUTER.TABLE0__HORA_5,
                TABLE0_OUTER.TABLE0__IDAREA_1,
                TABLE0_OUTER.TABLE0__IDCARGO_1,
                TABLE0_OUTER.TABLE0__IDENTIFICADOR_1,
                TABLE0_OUTER.TABLE0__IDPRINCIPAL_1,
                TABLE0_OUTER.TABLE0__IDTEAM_1,
                TABLE0_OUTER.TABLE0__LOGI_1,
                TABLE0_OUTER.TABLE0__LUGAR_1,
                TABLE0_OUTER.TABLE0__NOMBRECOMPLETO_1,
                TABLE0_OUTER.TABLE0__NOMBRES_1,
                TABLE0_OUTER.TABLE0__NOMBRECONYUGE_1,
                TABLE0_OUTER.TABLE0__NREG_1,
                TABLE0_OUTER.TABLE0__NPASAPORTE_1,
                TABLE0_OUTER.TABLE0__PASAPORTECONYUG_1,
                TABLE0_OUTER.TABLE0__RDBRUT_3,
                TABLE0_OUTER.TABLE0__RDBRUTCONYUGE_3,
                TABLE0_OUTER.TABLE0__REGISTROEXISTEN_1,
                TABLE0_OUTER.TABLE0__RESALG_1,
                TABLE0_OUTER.TABLE0__RESULTADOWS_11,
                TABLE0_OUTER.TABLE0__RESULTADOQUERY_2,
                TABLE0_OUTER.TABLE0__RUT_1,
                TABLE0_OUTER.TABLE0__RUTCONYUGE_1,
                TABLE0_OUTER.TABLE0__TELEFONO_1,
                TABLE0_OUTER.TABLE0__TEMPORAL_1,
                TABLE0_OUTER.TABLE0_REF0_CARGO_1,
                TABLE0_OUTER.TABLE0_REF1_TIPOACCION_1,
                TABLE0_OUTER.TABLE0_REF2_PERSONA_1,
                TABLE0_OUTER.TABLE0_REF2_IDPERSONA_1,
                TABLE0_OUTER.TRAN_rutfinal,
                TABLE0_OUTER.TRAN_pasaportefinal,
                TABLE0_OUTER.TRAN_nombrefinal,
                TABLE0_OUTER.TRAN_fechatransaccio,
                TABLE0_OUTER.TRAN_foliotransaccio,
                TABLE0_OUTER.TRAN_fechaperfeccion,
                TABLE0_OUTER.TRAN_rutemisor,
                TABLE0_OUTER.TRAN_nombreemisor,
                TABLE0_OUTER.TRAN_serie,
                TABLE0_OUTER.TRAN_nemotecnico,
                TABLE0_OUTER.TRAN_unidades,
                TABLE0_OUTER.TRAN_moneda2,
                TABLE0_OUTER.TRAN_preciounitario3,
                TABLE0_OUTER.TRAN_valortotal3,
                TABLE0_OUTER.TRAN_compraventa,
                TABLE0_OUTER.TRAN_intermediario,
                TABLE0_OUTER.TRAN_tir,
                TABLE0_OUTER.TRAN_codigotransac,
                TABLE0_OUTER.TRAN_cargo,
                TABLE0_OUTER.TRAN_tipoinstrumento,
                TABLE0_OUTER.TRAN_usuariotransaccion
            FROM
                WFPROCESS WFP 
            LEFT OUTER JOIN
                GNREVISION GNREV 
                    ON WFP.CDREVISION=GNREV.CDREVISION 
            LEFT OUTER JOIN
                ADUSER ADU 
                    ON ADU.CDUSER=WFP.CDUSERSTART 
            LEFT OUTER JOIN
                (
                    SELECT
                        ADEXTERNALUSER.CDEXTERNALUSER,
                        ADCOMPANY.NMCOMPANY,
                        ADEXTERNALUSER.NMUSER 
                    FROM
                        ADEXTERNALUSER 
                    INNER JOIN
                        ADCOMPANY 
                            ON ADEXTERNALUSER.CDCOMPANY=ADCOMPANY.CDCOMPANY
                    ) TBEXT 
                        ON WFP.CDEXTERNALUSERSTART=TBEXT.CDEXTERNALUSER 
                LEFT OUTER JOIN
                    GNSLACONTROL SLACTRL 
                        ON WFP.CDSLACONTROL=SLACTRL.CDSLACONTROL 
                LEFT OUTER JOIN
                    GNREVISIONSTATUS GNRS 
                        ON WFP.CDSTATUS=GNRS.CDREVISIONSTATUS 
                LEFT OUTER JOIN
                    GNEVALRESULTUSED GNRUS 
                        ON GNRUS.CDEVALRESULTUSED=WFP.CDEVALRSLTPRIORITY 
                LEFT OUTER JOIN
                    GNEVALRESULT GNR 
                        ON GNRUS.CDEVALRESULT=GNR.CDEVALRESULT 
                LEFT OUTER JOIN
                    INOCCURRENCE INOCCUR 
                        ON WFP.IDOBJECT=INOCCUR.IDWORKFLOW 
                LEFT OUTER JOIN
                    GNGENTYPE GNT 
                        ON INOCCUR.CDOCCURRENCETYPE=GNT.CDGENTYPE 
                LEFT OUTER JOIN
                    PMACTIVITY PP 
                        ON PP.CDACTIVITY=WFP.CDPROCESSMODEL 
                LEFT OUTER JOIN
                    PMACTTYPE PT 
                        ON PT.CDACTTYPE=PP.CDACTTYPE 
                LEFT OUTER JOIN
                    (
                        SELECT
                            FORMREG.CDASSOC,
                            TABLE0.ADJUNTARANEXOB AS TABLE0__ADJUNTARANEXOB_1,
                            TABLE0.APELLIDOM AS TABLE0__APELLIDOM_1,
                            TABLE0.APELLIDOMCONYUG AS TABLE0__APELLIDOMCONYUG_1,
                            TABLE0.APELLIDOP AS TABLE0__APELLIDOP_1,
                            TABLE0.APELLIDOPCONYUG AS TABLE0__APELLIDOPCONYUG_1,
                            TABLE0.AREA AS TABLE0__AREA_1,
                            TABLE0.CARGO AS TABLE0__CARGO_1,
                            TABLE0.CASADO AS TABLE0__CASADO_3,
                            TABLE0.COMENTARIOSVERI AS TABLE0__COMENTARIOSVERI_2,
                            TABLE0.CORREO AS TABLE0__CORREO_1,
                            TABLE0.CDUSER AS TABLE0__CDUSER_1,
                            TABLE0.DOMICILIO AS TABLE0__DOMICILIO_1,
                            TABLE0.FECHACAPACITACI AS TABLE0__FECHACAPACITACI_6,
                            TABLE0.FECHAEJECUCION AS TABLE0__FECHAEJECUCION_6,
                            TABLE0.FECHAINGRESO AS TABLE0__FECHAINGRESO_6,
                            TABLE0.FECHAMATRIMONIO AS TABLE0__FECHAMATRIMONIO_6,
                            TABLE0.FECHATERMINO AS TABLE0__FECHATERMINO_6,
                            TABLE0.FECHAPLAZO AS TABLE0__FECHAPLAZO_6,
                            TABLE0.FECHAREG AS TABLE0__FECHAREG_6,
                            CAST(TABLE0.HORA AS NUMERIC(19)) * 1000 AS TABLE0__HORA_5,
                            TABLE0.IDAREA AS TABLE0__IDAREA_1,
                            TABLE0.IDCARGO AS TABLE0__IDCARGO_1,
                            TABLE0.IDENTIFICADOR AS TABLE0__IDENTIFICADOR_1,
                            TABLE0.IDPRINCIPAL AS TABLE0__IDPRINCIPAL_1,
                            TABLE0.IDTEAM AS TABLE0__IDTEAM_1,
                            TABLE0.LOGI AS TABLE0__LOGI_1,
                            TABLE0.LUGAR AS TABLE0__LUGAR_1,
                            TABLE0.NOMBRECOMPLETO AS TABLE0__NOMBRECOMPLETO_1,
                            TABLE0.NOMBRES AS TABLE0__NOMBRES_1,
                            TABLE0.NOMBRECONYUGE AS TABLE0__NOMBRECONYUGE_1,
                            TABLE0.NREG AS TABLE0__NREG_1,
                            TABLE0.NPASAPORTE AS TABLE0__NPASAPORTE_1,
                            TABLE0.PASAPORTECONYUG AS TABLE0__PASAPORTECONYUG_1,
                            TABLE0.RDBRUT AS TABLE0__RDBRUT_3,
                            TABLE0.RDBRUTCONYUGE AS TABLE0__RDBRUTCONYUGE_3,
                            TABLE0.REGISTROEXISTEN AS TABLE0__REGISTROEXISTEN_1,
                            TABLE0.RESALG AS TABLE0__RESALG_1,
                            TABLE0.RESULTADOWS AS TABLE0__RESULTADOWS_11,
                            TABLE0.RESULTADOQUERY AS TABLE0__RESULTADOQUERY_2,
                            TABLE0.RUT AS TABLE0__RUT_1,
                            TABLE0.RUTCONYUGE AS TABLE0__RUTCONYUGE_1,
                            TABLE0.TELEFONO AS TABLE0__TELEFONO_1,
                            TABLE0.TEMPORAL AS TABLE0__TEMPORAL_1,
                            REF0.CARGO AS TABLE0_REF0_CARGO_1,
                            REF1.TIPOACCION AS TABLE0_REF1_TIPOACCION_1,
                            REF2.PERSONA AS TABLE0_REF2_PERSONA_1,
                            REF2.IDPERSONA AS TABLE0_REF2_IDPERSONA_1,
                            GRID.rutfinal TRAN_rutfinal,
                            GRID.pasaportefinal TRAN_pasaportefinal,
                            trim(regexp_replace(GRID.nombrefinal, '\s+', ' ', 'g')) TRAN_nombrefinal,
                            GRID.fechatransaccio TRAN_fechatransaccio,
                            GRID.foliotransaccio TRAN_foliotransaccio,
                            GRID.fechaperfeccion TRAN_fechaperfeccion,
                            GRID.rutemisor TRAN_rutemisor,
                            GRID.nombreemisor TRAN_nombreemisor,
                            GRID.serie TRAN_serie,
                            GRID.nemotecnico TRAN_nemotecnico,
                            GRID.unidades TRAN_unidades,
                            GRID.moneda TRAN_moneda2,
                            GRID.preciounitario3 TRAN_preciounitario3,
                            GRID.valortotal3 TRAN_valortotal3,
                            GRID.compraventa TRAN_compraventa,
                            GRID.intermediario TRAN_intermediario,
                            GRID.tir TRAN_tir,
                            GRID.codigotransanc TRAN_codigotransac,
                            REF1GRID.cargo TRAN_cargo,
                            REF2GRID.tipoinstrumento TRAN_tipoinstrumento, 
                            REF3GRID.usuariotransacc TRAN_usuariotransaccion
                        FROM
                            GNASSOCFORMREG FORMREG 
                        INNER JOIN
                            DYNci TABLE0 
                                ON (
                                    FORMREG.OIDENTITYREG=TABLE0.OID
                                ) 
                        LEFT OUTER JOIN
                            DYNformcargo REF0 
                                ON (
                                    TABLE0.OIDABCE0RCAPNY60DK=REF0.OID
                                ) 
                        LEFT OUTER JOIN
                            DYNformtipoaccion REF1 
                                ON (
                                    TABLE0.OIDABC1YIIG4CHH9WK=REF1.OID
                                ) 
                        LEFT OUTER JOIN
                            DYNformpersona REF2 
                                ON (
                                    TABLE0.OIDABC00JGS4Y3SN89=REF2.OID
                                )
                      
                      LEFT OUTER JOIN
                            DYNgridtransaccion GRID                                                                   
                                ON (
                                    TABLE0.OID = GRID.OIDABCQHX6WA85BDDT                                                                   
                                )    

                        LEFT OUTER JOIN
                            DYNformcargo REF1GRID                                                                                                   
                                ON (
                                    GRID.OIDABC2F7XC1F94T66=REF1GRID.OID 
                                )
                        LEFT OUTER JOIN
                            DYNforminstrumento REF2GRID                                                                                                   
                                ON (
                                    GRID.OIDABCSLS4XD3HSZ1V=REF2GRID.OID 
                                )
                      
                      LEFT OUTER JOIN
                            dynformusrtran REF3GRID                                                                                                   
                                ON (
                                    GRID.OIDABC46ER5AKHDDY9=REF3GRID.OID 
                                )

                      
                        ) TABLE0_OUTER 
                            ON (
                                TABLE0_OUTER.CDASSOC=WFP.CDASSOCREG
                            ) 
                    INNER JOIN
                        (
                            SELECT
                                DISTINCT Z.IDOBJECT 
                            FROM
                                (SELECT
                                    AUXWFP.IDOBJECT 
                                FROM
                                    WFPROCESS AUXWFP 
                                INNER JOIN
                                    (
                                        SELECT
                                            PERM.USERCD,
                                            PERM.IDPROCESS,
                                            MIN(PERM.FGPERMISSION) AS FGPERMISSION 
                                        FROM
                                            (SELECT
                                                WF.FGPERMISSION,
                                                WF.IDPROCESS,
                                                TM.CDUSER AS USERCD,
                                                WF.CDACCESSLIST 
                                            FROM
                                                WFPROCSECURITYLIST WF 
                                            INNER JOIN
                                                ADTEAMUSER TM 
                                                    ON WF.CDTEAM=TM.CDTEAM 
                                            WHERE
                                                WF.FGACCESSTYPE=1 
                                                AND TM.CDUSER=1 
                                                AND WF.FGACCESSEXCEPTION IS NULL 
                                            UNION
                                            ALL SELECT
                                                WF.FGPERMISSION,
                                                WF.IDPROCESS,
                                                UDP.CDUSER AS USERCD,
                                                WF.CDACCESSLIST 
                                            FROM
                                                WFPROCSECURITYLIST WF 
                                            INNER JOIN
                                                ADUSERDEPTPOS UDP 
                                                    ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT 
                                            WHERE
                                                WF.FGACCESSTYPE=2 
                                                AND UDP.CDUSER=1 
                                                AND WF.FGACCESSEXCEPTION IS NULL 
                                            UNION
                                            ALL SELECT
                                                WF.FGPERMISSION,
                                                WF.IDPROCESS,
                                                UDP.CDUSER AS USERCD,
                                                WF.CDACCESSLIST 
                                            FROM
                                                WFPROCSECURITYLIST WF 
                                            INNER JOIN
                                                ADUSERDEPTPOS UDP 
                                                    ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT 
                                                    AND WF.CDPOSITION=UDP.CDPOSITION 
                                            WHERE
                                                WF.FGACCESSTYPE=3 
                                                AND UDP.CDUSER=1 
                                                AND WF.FGACCESSEXCEPTION IS NULL 
                                            UNION
                                            ALL SELECT
                                                WF.FGPERMISSION,
                                                WF.IDPROCESS,
                                                UDP.CDUSER AS USERCD,
                                                WF.CDACCESSLIST 
                                            FROM
                                                WFPROCSECURITYLIST WF 
                                            INNER JOIN
                                                ADUSERDEPTPOS UDP 
                                                    ON WF.CDPOSITION=UDP.CDPOSITION 
                                            WHERE
                                                WF.FGACCESSTYPE=4 
                                                AND UDP.CDUSER=1 
                                                AND WF.FGACCESSEXCEPTION IS NULL 
                                            UNION
                                            ALL SELECT
                                                WF.FGPERMISSION,
                                                WF.IDPROCESS,
                                                WF.CDUSER AS USERCD,
                                                WF.CDACCESSLIST 
                                            FROM
                                                WFPROCSECURITYLIST WF 
                                            WHERE
                                                WF.FGACCESSTYPE=5 
                                                AND WF.CDUSER=1 
                                                AND WF.FGACCESSEXCEPTION IS NULL 
                                            UNION
                                            ALL SELECT
                                                WF.FGPERMISSION,
                                                WF.IDPROCESS,
                                                US.CDUSER AS USERCD,
                                                WF.CDACCESSLIST 
                                            FROM
                                                WFPROCSECURITYLIST WF CROSS 
                                            JOIN
                                                ADUSER US 
                                            WHERE
                                                WF.FGACCESSTYPE=6 
                                                AND US.CDUSER=1 
                                                AND WF.FGACCESSEXCEPTION IS NULL 
                                            UNION
                                            ALL SELECT
                                                WF.FGPERMISSION,
                                                WF.IDPROCESS,
                                                RL.CDUSER AS USERCD,
                                                WF.CDACCESSLIST 
                                            FROM
                                                WFPROCSECURITYLIST WF 
                                            INNER JOIN
                                                ADUSERROLE RL 
                                                    ON RL.CDROLE=WF.CDROLE 
                                            WHERE
                                                WF.FGACCESSTYPE=7 
                                                AND RL.CDUSER=1 
                                                AND WF.FGACCESSEXCEPTION IS NULL 
                                            UNION
                                            ALL SELECT
                                                WF.FGPERMISSION,
                                                WF.IDPROCESS,
                                                WFP.CDUSERSTART AS USERCD,
                                                WF.CDACCESSLIST 
                                            FROM
                                                WFPROCSECURITYLIST WF 
                                            INNER JOIN
                                                WFPROCESS WFP 
                                                    ON WFP.IDOBJECT=WF.IDPROCESS 
                                            WHERE
                                                WF.FGACCESSTYPE=30 
                                                AND WFP.CDUSERSTART=1 
                                                AND WF.FGACCESSEXCEPTION IS NULL 
                                            UNION
                                            ALL SELECT
                                                WF.FGPERMISSION,
                                                WF.IDPROCESS,
                                                US.CDLEADER AS USERCD,
                                                WF.CDACCESSLIST 
                                            FROM
                                                WFPROCSECURITYLIST WF 
                                            INNER JOIN
                                                WFPROCESS WFP 
                                                    ON WFP.IDOBJECT=WF.IDPROCESS 
                                            INNER JOIN
                                                ADUSER US 
                                                    ON US.CDUSER=WFP.CDUSERSTART 
                                            WHERE
                                                WF.FGACCESSTYPE=31 
                                                AND US.CDLEADER=1 
                                                AND WF.FGACCESSEXCEPTION IS NULL
                                        ) PERM 
                                    INNER JOIN
                                        WFPROCSECURITYCTRL GNASSOC 
                                            ON (
                                                GNASSOC.CDACCESSLIST=PERM.CDACCESSLIST 
                                                AND GNASSOC.IDPROCESS=PERM.IDPROCESS
                                            ) 
                                    WHERE
                                        GNASSOC.CDACCESSROLEFIELD IN (
                                            501
                                        ) 
                                    GROUP BY
                                        PERM.USERCD,
                                        PERM.IDPROCESS
                                ) PERMISSION 
                                    ON PERMISSION.IDPROCESS=AUXWFP.IDOBJECT 
                            WHERE
                                PERMISSION.FGPERMISSION=1 
                                AND AUXWFP.FGSTATUS <= 5 
                                AND (
                                    AUXWFP.FGMODELWFSECURITY IS NULL 
                                    OR AUXWFP.FGMODELWFSECURITY=0
                                ) 
                            UNION
                            ALL SELECT
                                T.IDOBJECT 
                            FROM
                                (SELECT
                                    MIN(PERM99.FGPERMISSION) AS FGPERMISSION,
                                    PERM99.IDOBJECT 
                                FROM
                                    (SELECT
                                        WFP.IDOBJECT,
                                        PERM1.FGPERMISSION 
                                    FROM
                                        (SELECT
                                            PP.FGPERMISSION,
                                            PP.CDPROC,
                                            PP.CDACCESSLIST,
                                            TM.CDUSER AS USERCD 
                                        FROM
                                            PMPROCACCESSLIST PP 
                                        INNER JOIN
                                            ADTEAMUSER TM 
                                                ON PP.CDTEAM=TM.CDTEAM 
                                        WHERE
                                            PP.FGACCESSTYPE=1 
                                            AND TM.CDUSER=1 
                                        UNION
                                        ALL SELECT
                                            PP.FGPERMISSION,
                                            PP.CDPROC,
                                            PP.CDACCESSLIST,
                                            UDP.CDUSER AS USERCD 
                                        FROM
                                            PMPROCACCESSLIST PP 
                                        INNER JOIN
                                            ADUSERDEPTPOS UDP 
                                                ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT 
                                        WHERE
                                            PP.FGACCESSTYPE=2 
                                            AND UDP.CDUSER=1 
                                        UNION
                                        ALL SELECT
                                            PP.FGPERMISSION,
                                            PP.CDPROC,
                                            PP.CDACCESSLIST,
                                            UDP.CDUSER AS USERCD 
                                        FROM
                                            PMPROCACCESSLIST PP 
                                        INNER JOIN
                                            ADUSERDEPTPOS UDP 
                                                ON (
                                                    PP.CDDEPARTMENT=UDP.CDDEPARTMENT 
                                                    AND PP.CDPOSITION=UDP.CDPOSITION
                                                ) 
                                        WHERE
                                            PP.FGACCESSTYPE=3 
                                            AND UDP.CDUSER=1 
                                        UNION
                                        ALL SELECT
                                            PP.FGPERMISSION,
                                            PP.CDPROC,
                                            PP.CDACCESSLIST,
                                            UDP.CDUSER AS USERCD 
                                        FROM
                                            PMPROCACCESSLIST PP 
                                        INNER JOIN
                                            ADUSERDEPTPOS UDP 
                                                ON PP.CDPOSITION=UDP.CDPOSITION 
                                        WHERE
                                            PP.FGACCESSTYPE=4 
                                            AND UDP.CDUSER=1 
                                        UNION
                                        ALL SELECT
                                            PP.FGPERMISSION,
                                            PP.CDPROC,
                                            PP.CDACCESSLIST,
                                            PP.CDUSER AS USERCD 
                                        FROM
                                            PMPROCACCESSLIST PP 
                                        WHERE
                                            PP.FGACCESSTYPE=5 
                                            AND PP.CDUSER=1 
                                        UNION
                                        ALL SELECT
                                            PP.FGPERMISSION,
                                            PP.CDPROC,
                                            PP.CDACCESSLIST,
                                            US.CDUSER AS USERCD 
                                        FROM
                                            PMPROCACCESSLIST PP CROSS 
                                        JOIN
                                            ADUSER US 
                                        WHERE
                                            PP.FGACCESSTYPE=6 
                                            AND US.CDUSER=1 
                                        UNION
                                        ALL SELECT
                                            PP.FGPERMISSION,
                                            PP.CDPROC,
                                            PP.CDACCESSLIST,
                                            RL.CDUSER AS USERCD 
                                        FROM
                                            PMPROCACCESSLIST PP 
                                        INNER JOIN
                                            ADUSERROLE RL 
                                                ON RL.CDROLE=PP.CDROLE 
                                        WHERE
                                            PP.FGACCESSTYPE=7 
                                            AND RL.CDUSER=1
                                    ) PERM1 
                                INNER JOIN
                                    PMPROCSECURITYCTRL GNASSOC 
                                        ON (
                                            PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST 
                                            AND PERM1.CDPROC=GNASSOC.CDPROC
                                        ) 
                                INNER JOIN
                                    PMACCESSROLEFIELD GNCTRL 
                                        ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD 
                                INNER JOIN
                                    PMACTIVITY OBJ 
                                        ON GNASSOC.CDPROC=OBJ.CDACTIVITY 
                                INNER JOIN
                                    WFPROCESS WFP 
                                        ON WFP.CDPROCESSMODEL=PERM1.CDPROC 
                                WHERE
                                    GNCTRL.CDRELATEDFIELD IN (
                                        501
                                    ) 
                                    AND (
                                        OBJ.FGUSETYPEACCESS=0 
                                        OR OBJ.FGUSETYPEACCESS IS NULL
                                    ) 
                                    AND WFP.FGMODELWFSECURITY=1 
                                    AND WFP.FGSTATUS <= 5 
                                UNION
                                ALL SELECT
                                    PERM2.IDOBJECT,
                                    PERM2.FGPERMISSION 
                                FROM
                                    (SELECT
                                        PP.FGPERMISSION,
                                        WFP.IDOBJECT,
                                        PP.CDPROC,
                                        PP.CDACCESSLIST,
                                        WFP.CDUSERSTART AS USERCD 
                                    FROM
                                        PMPROCACCESSLIST PP 
                                    INNER JOIN
                                        WFPROCESS WFP 
                                            ON WFP.CDPROCESSMODEL=PP.CDPROC 
                                    WHERE
                                        PP.FGACCESSTYPE=30 
                                        AND WFP.CDUSERSTART=1 
                                        AND WFP.FGMODELWFSECURITY=1 
                                        AND WFP.FGSTATUS <= 5 
                                    UNION
                                    ALL SELECT
                                        PP.FGPERMISSION,
                                        WFP.IDOBJECT,
                                        PP.CDPROC,
                                        PP.CDACCESSLIST,
                                        US.CDLEADER AS USERCD 
                                    FROM
                                        PMPROCACCESSLIST PP 
                                    INNER JOIN
                                        WFPROCESS WFP 
                                            ON WFP.CDPROCESSMODEL=PP.CDPROC 
                                    INNER JOIN
                                        ADUSER US 
                                            ON US.CDUSER=WFP.CDUSERSTART 
                                    WHERE
                                        PP.FGACCESSTYPE=31 
                                        AND US.CDLEADER=1 
                                        AND WFP.FGMODELWFSECURITY=1 
                                        AND WFP.FGSTATUS <= 5
                                ) PERM2 
                            INNER JOIN
                                PMPROCSECURITYCTRL GNASSOC 
                                    ON (
                                        PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST 
                                        AND PERM2.CDPROC=GNASSOC.CDPROC
                                    ) 
                            INNER JOIN
                                PMACCESSROLEFIELD GNCTRL 
                                    ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD 
                            INNER JOIN
                                PMACTIVITY OBJ 
                                    ON GNASSOC.CDPROC=OBJ.CDACTIVITY 
                            WHERE
                                GNCTRL.CDRELATEDFIELD IN (
                                    501
                                ) 
                                AND (
                                    OBJ.FGUSETYPEACCESS=0 
                                    OR OBJ.FGUSETYPEACCESS IS NULL
                                )) PERM99 
                        WHERE
                            1=1 
                        GROUP BY
                            PERM99.IDOBJECT) T 
                        WHERE
                            T.FGPERMISSION=1 
                        UNION
                        ALL SELECT
                            T.IDOBJECT 
                        FROM
                            (SELECT
                                PERM.IDOBJECT,
                                MIN(PERM.FGPERMISSION) AS FGPERMISSION 
                            FROM
                                (SELECT
                                    WFP.IDOBJECT,
                                    PMA.FGUSETYPEACCESS,
                                    PERM1.FGPERMISSION 
                                FROM
                                    (SELECT
                                        PM.FGPERMISSION,
                                        PM.CDACTTYPE,
                                        PM.CDACCESSLIST,
                                        TM.CDUSER AS USERCD 
                                    FROM
                                        PMACTTYPESECURLIST PM 
                                    INNER JOIN
                                        ADTEAMUSER TM 
                                            ON PM.CDTEAM=TM.CDTEAM 
                                    WHERE
                                        PM.FGACCESSTYPE=1 
                                        AND TM.CDUSER=1 
                                    UNION
                                    ALL SELECT
                                        PM.FGPERMISSION,
                                        PM.CDACTTYPE,
                                        PM.CDACCESSLIST,
                                        UDP.CDUSER AS USERCD 
                                    FROM
                                        PMACTTYPESECURLIST PM 
                                    INNER JOIN
                                        ADUSERDEPTPOS UDP 
                                            ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT 
                                    WHERE
                                        PM.FGACCESSTYPE=2 
                                        AND UDP.CDUSER=1 
                                    UNION
                                    ALL SELECT
                                        PM.FGPERMISSION,
                                        PM.CDACTTYPE,
                                        PM.CDACCESSLIST,
                                        UDP.CDUSER AS USERCD 
                                    FROM
                                        PMACTTYPESECURLIST PM 
                                    INNER JOIN
                                        ADUSERDEPTPOS UDP 
                                            ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT 
                                            AND PM.CDPOSITION=UDP.CDPOSITION 
                                    WHERE
                                        PM.FGACCESSTYPE=3 
                                        AND UDP.CDUSER=1 
                                    UNION
                                    ALL SELECT
                                        PM.FGPERMISSION,
                                        PM.CDACTTYPE,
                                        PM.CDACCESSLIST,
                                        UDP.CDUSER AS USERCD 
                                    FROM
                                        PMACTTYPESECURLIST PM 
                                    INNER JOIN
                                        ADUSERDEPTPOS UDP 
                                            ON PM.CDPOSITION=UDP.CDPOSITION 
                                    WHERE
                                        PM.FGACCESSTYPE=4 
                                        AND UDP.CDUSER=1 
                                    UNION
                                    ALL SELECT
                                        PM.FGPERMISSION,
                                        PM.CDACTTYPE,
                                        PM.CDACCESSLIST,
                                        PM.CDUSER AS USERCD 
                                    FROM
                                        PMACTTYPESECURLIST PM 
                                    WHERE
                                        PM.FGACCESSTYPE=5 
                                        AND PM.CDUSER=1 
                                    UNION
                                    ALL SELECT
                                        PM.FGPERMISSION,
                                        PM.CDACTTYPE,
                                        PM.CDACCESSLIST,
                                        US.CDUSER AS USERCD 
                                    FROM
                                        PMACTTYPESECURLIST PM CROSS 
                                    JOIN
                                        ADUSER US 
                                    WHERE
                                        PM.FGACCESSTYPE=6 
                                        AND US.CDUSER=1 
                                    UNION
                                    ALL SELECT
                                        PM.FGPERMISSION,
                                        PM.CDACTTYPE,
                                        PM.CDACCESSLIST,
                                        RL.CDUSER AS USERCD 
                                    FROM
                                        PMACTTYPESECURLIST PM 
                                    INNER JOIN
                                        ADUSERROLE RL 
                                            ON RL.CDROLE=PM.CDROLE 
                                    WHERE
                                        PM.FGACCESSTYPE=7 
                                        AND RL.CDUSER=1
                                ) PERM1 
                            INNER JOIN
                                PMACTTYPESECURCTRL GNASSOC 
                                    ON (
                                        PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST 
                                        AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE
                                    ) 
                            INNER JOIN
                                PMACCESSROLEFIELD GNCTRL 
                                    ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD 
                            INNER JOIN
                                PMACCESSROLEFIELD GNCTRL_F 
                                    ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD 
                            INNER JOIN
                                PMACTIVITY PMA 
                                    ON PERM1.CDACTTYPE=PMA.CDACTTYPE 
                            INNER JOIN
                                WFPROCESS WFP 
                                    ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL 
                            WHERE
                                GNCTRL_F.CDRELATEDFIELD IN (
                                    501
                                ) 
                                AND WFP.FGSTATUS <= 5 
                                AND PMA.FGUSETYPEACCESS=1 
                                AND WFP.FGMODELWFSECURITY=1 
                            UNION
                            ALL SELECT
                                WFP.IDOBJECT,
                                PMA.FGUSETYPEACCESS,
                                PERM2.FGPERMISSION 
                            FROM
                                (SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    PMA.CDCREATEDBY AS USERCD 
                                FROM
                                    PMACTTYPESECURLIST PM 
                                INNER JOIN
                                    PMACTIVITY PMA 
                                        ON PM.CDACTTYPE=PMA.CDACTTYPE 
                                WHERE
                                    PM.FGACCESSTYPE=8 
                                    AND PMA.CDCREATEDBY=1 
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    DEP2.CDUSER 
                                FROM
                                    PMACTTYPESECURLIST PM 
                                INNER JOIN
                                    PMACTIVITY PMA 
                                        ON PM.CDACTTYPE=PMA.CDACTTYPE 
                                INNER JOIN
                                    ADUSERDEPTPOS DEP1 
                                        ON DEP1.CDUSER=PMA.CDCREATEDBY 
                                INNER JOIN
                                    ADUSERDEPTPOS DEP2 
                                        ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT 
                                WHERE
                                    PM.FGACCESSTYPE=9 
                                    AND DEP2.CDUSER=1 
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    DEP2.CDUSER 
                                FROM
                                    PMACTTYPESECURLIST PM 
                                INNER JOIN
                                    PMACTIVITY PMA 
                                        ON PM.CDACTTYPE=PMA.CDACTTYPE 
                                INNER JOIN
                                    ADUSERDEPTPOS DEP1 
                                        ON DEP1.CDUSER=PMA.CDCREATEDBY 
                                INNER JOIN
                                    ADUSERDEPTPOS DEP2 
                                        ON (
                                            DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT 
                                            AND DEP2.CDPOSITION=DEP1.CDPOSITION
                                        ) 
                                WHERE
                                    PM.FGACCESSTYPE=10 
                                    AND DEP2.CDUSER=1 
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    DEP2.CDUSER 
                                FROM
                                    PMACTTYPESECURLIST PM 
                                INNER JOIN
                                    PMACTIVITY PMA 
                                        ON PM.CDACTTYPE=PMA.CDACTTYPE 
                                INNER JOIN
                                    ADUSERDEPTPOS DEP1 
                                        ON DEP1.CDUSER=PMA.CDCREATEDBY 
                                INNER JOIN
                                    ADUSERDEPTPOS DEP2 
                                        ON DEP2.CDPOSITION=DEP1.CDPOSITION 
                                WHERE
                                    PM.FGACCESSTYPE=11 
                                    AND DEP2.CDUSER=1 
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    US.CDLEADER 
                                FROM
                                    PMACTTYPESECURLIST PM 
                                INNER JOIN
                                    PMACTIVITY PMA 
                                        ON PM.CDACTTYPE=PMA.CDACTTYPE 
                                INNER JOIN
                                    ADUSER US 
                                        ON US.CDUSER=PMA.CDCREATEDBY 
                                WHERE
                                    PM.FGACCESSTYPE=12 
                                    AND US.CDLEADER=1
                            ) PERM2 
                        INNER JOIN
                            PMACTTYPESECURCTRL GNASSOC 
                                ON (
                                    PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST 
                                    AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE
                                ) 
                        INNER JOIN
                            PMACCESSROLEFIELD GNCTRL 
                                ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD 
                        INNER JOIN
                            PMACCESSROLEFIELD GNCTRL_F 
                                ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD 
                        INNER JOIN
                            PMACTIVITY PMA 
                                ON PERM2.CDACTTYPE=PMA.CDACTTYPE 
                        INNER JOIN
                            WFPROCESS WFP 
                                ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL 
                        WHERE
                            GNCTRL_F.CDRELATEDFIELD IN (
                                501
                            ) 
                            AND WFP.FGSTATUS <= 5 
                            AND PMA.FGUSETYPEACCESS=1 
                            AND WFP.FGMODELWFSECURITY=1 
                        UNION
                        ALL SELECT
                            PERM3.IDOBJECT,
                            PMA.FGUSETYPEACCESS,
                            PERM3.FGPERMISSION 
                        FROM
                            (SELECT
                                PM.FGPERMISSION,
                                PM.CDACTTYPE,
                                PM.CDACCESSLIST,
                                WFP.CDUSERSTART AS USERCD,
                                WFP.IDOBJECT 
                            FROM
                                PMACTTYPESECURLIST PM 
                            INNER JOIN
                                PMACTIVITY PMA 
                                    ON PM.CDACTTYPE=PMA.CDACTTYPE 
                            INNER JOIN
                                WFPROCESS WFP 
                                    ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL 
                            WHERE
                                PM.FGACCESSTYPE=30 
                                AND WFP.CDUSERSTART=1 
                                AND WFP.FGSTATUS <= 5 
                                AND WFP.FGMODELWFSECURITY=1 
                            UNION
                            ALL SELECT
                                PM.FGPERMISSION,
                                PM.CDACTTYPE,
                                PM.CDACCESSLIST,
                                US.CDLEADER AS USERCD,
                                WFP.IDOBJECT 
                            FROM
                                PMACTTYPESECURLIST PM 
                            INNER JOIN
                                PMACTIVITY PMA 
                                    ON PM.CDACTTYPE=PMA.CDACTTYPE 
                            INNER JOIN
                                WFPROCESS WFP 
                                    ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL 
                            INNER JOIN
                                ADUSER US 
                                    ON US.CDUSER=WFP.CDUSERSTART 
                            WHERE
                                PM.FGACCESSTYPE=31 
                                AND US.CDLEADER=1 
                                AND WFP.FGSTATUS <= 5 
                                AND WFP.FGMODELWFSECURITY=1
                        ) PERM3 
                    INNER JOIN
                        PMACTTYPESECURCTRL GNASSOC 
                            ON (
                                PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST 
                                AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE
                            ) 
                    INNER JOIN
                        PMACCESSROLEFIELD GNCTRL 
                            ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD 
                    INNER JOIN
                        PMACCESSROLEFIELD GNCTRL_F 
                            ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD 
                    INNER JOIN
                        PMACTIVITY PMA 
                            ON PERM3.CDACTTYPE=PMA.CDACTTYPE 
                    WHERE
                        GNCTRL_F.CDRELATEDFIELD IN (
                            501
                        ) 
                        AND PMA.FGUSETYPEACCESS=1) PERM 
                GROUP BY
                    PERM.IDOBJECT) T 
                WHERE
                    T.FGPERMISSION=1 
                UNION
                ALL SELECT
                    AUXWFP.IDOBJECT 
                FROM
                    WFPROCESS AUXWFP 
                INNER JOIN
                    WFPROCSECURITYLIST WFLIST 
                        ON (
                            AUXWFP.IDOBJECT=WFLIST.IDPROCESS
                        ) 
                INNER JOIN
                    WFPROCSECURITYCTRL WFCTRL 
                        ON (
                            WFLIST.CDACCESSLIST=WFCTRL.CDACCESSLIST 
                            AND WFLIST.IDPROCESS=WFCTRL.IDPROCESS
                        ) 
                WHERE
                    WFCTRL.CDACCESSROLEFIELD IN (
                        501
                    ) 
                    AND WFLIST.CDUSER=1 
                    AND WFLIST.FGACCESSTYPE=5 
                    AND WFLIST.FGACCESSEXCEPTION=1 
                    AND WFLIST.FGPERMISSION=1 
                    AND AUXWFP.FGSTATUS <= 5
            ) Z
    ) MYPERM 
        ON (
            WFP.IDOBJECT=MYPERM.IDOBJECT
        ) 
WHERE
    WFP.FGSTATUS <= 5 
    AND (
        WFP.CDPRODAUTOMATION IS NULL 
        OR WFP.CDPRODAUTOMATION NOT IN(
            160, 202, 275
        )
    ) 
    AND WFP.CDPROCESSMODEL=26
) TEMPTB0
) TEMPTB1 ) TMP 
LEFT JOIN
(SELECT DISTINCT CASE WHEN CONINT.NPASAPORTE IS NULL THEN TRIM(CONINT.RUT) ELSE TRIM(CONINT.NPASAPORTE) END IDENTIFICADOR, 
    trim(CONINT.NOMBRES) NOMBRE, 
    trim(CONINT.APELLIDOP) APELLIDO_PATERNO, 
    trim(CONINT.APELLIDOM) APELLIDO_MATERNO
FROM WFPROCESS WFP 
LEFT OUTER JOIN GNASSOCFORMREG FORMREG ON FORMREG.CDASSOC=WFP.CDASSOCREG
INNER JOIN DYNci CONINT ON FORMREG.OIDENTITYREG=CONINT.OID
WHERE WFP.FGSTATUS <= 5 AND WFP.CDPROCESSMODEL = 7) NOMBAPELL ON NOMBAPELL.IDENTIFICADOR = TMP.IDENTIFICADOR
        