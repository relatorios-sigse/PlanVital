SELECT
/**
Modificaciones:
28-08-2020. Andrés Del Río. Ajuste en Cargo. Para las sociedades relacionadas, el cargo debe estar siempre vacío.
28-08-2020. Andrés Del Río. Ajuste en % de participación. Cuando el Tipo es PERSONA SUJETA no debe tener cero porcentaje, debe estar vacío, igual que el cónyuge.
22-10-2020. Andrés Del Río. Ajuste para mostrar solo las informaciones de las Personas Sujetas, ahora que el flujo incluye a los Dependientes también.
06-11-2020. Andrés Del Río. Ajuste para mostrar el campo nulo cuando el porcentaje de participación en las sociedades es 0.
09-12-2020. Andrés Del Río. Paso a producción tras validación por parte del cliente. Se comentan líneas con "AND WFP.CDPROCESSMODEL=34" y se descomentan líneas con "AND WFP.CDPROCESSMODEL=7"
05-01-2021. Andrés Del Río. Ajuste en campo NOMBRE_PR_O_CON_INFOR en los registros de cónyuge, ya que no aparecían los nombres de las personas sujetas. Se modificó el cógigo
para permitir que el nombre de la personas sujeta no contenga alguno de los apellidos.
**/
		(SELECT NMUSER FROM ADUSER WHERE IDUSER = REP.IDENTIFICADOR_REPORTE) NOMBRE_USUARIO_REPORTE,
        REP.* 
    FROM
        (SELECT
            '1' ORDEN,
            'PERSONA SUJETA' TIPO,
            CONINT.IDENTIFICADOR IDENTIFICADOR_REPORTE,
            WFP.IDPROCESS,
            CASE WHEN CONINT.APELLIDOM <> '' THEN CONINT.APELLIDOP || ' ' || CONINT.APELLIDOM || ' ' || CONINT.NOMBRES 
        	ELSE CONINT.APELLIDOP || ' ' || CONINT.NOMBRES
            END NOMBRE_RS,
            CONINT.IDENTIFICADOR RUT,
            RELACION.CARGO RELACION_POSICION,
            CASE WHEN CONINT.CARGO = 'Otros Relacionados' THEN '' ELSE CONINT.CARGO END CARGO,
            '' NOMBRE_EMPRESA,
            '' RUT_EMPRESA,
		   	CONINT.fechaingreso FECHA_INICIO_RP, 
            /**DATEADD(day,1,CONINT.fechaingreso) FECHA_INICIO_RP,**/
            CONINT.fechatermino FECHA_TERMINO_RP,
            '' NOMBRE_PR_O_CON_INFOR,
            '' RUT_PR_O_CON_INFOR,
            '' NR,
            CASE WHEN CONINT.IDENTIFICADOR = '96929390-0' OR CONINT.IDENTIFICADOR = '96654350-7' OR CONINT.IDENTIFICADOR = '96955270-1' OR CONINT.IDENTIFICADOR = '76237243-6' THEN CONINT.dcaltaparticipa ELSE CAST(NULL AS NUMERIC) END PORC_PARTICIPACION,
            '' NOMBRE_SOC_INTERMED,
            '' RUT_SOC_INTERMED,
            CAST(NULL AS DATE) FECHA_CONSTITUCION_SOCIE,
            1 CANTIDAD,
            TIPOPERSONA.PERSONA TIPO_PERSONA
        FROM
            WFPROCESS WFP 
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID  
        LEFT OUTER JOIN
            DYNFORMCARGO RELACION 
                ON RELACION.OID = CONINT.OIDABCE0RCAPNY60DK
        LEFT OUTER JOIN 
            DYNFORMPERSONA TIPOPERSONA
                ON TIPOPERSONA.OID = CONINT.OIDABC00JGS4Y3SN89
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL=7
            --AND WFP.CDPROCESSMODEL=34
            AND TIPOPERSONA.IDPERSONA = 'GP-S' 
            AND (CONINT.fechatermino + interval '1 year' >= current_date OR CONINT.fechatermino IS NULL)
        UNION
        SELECT
            '2' ORDEN,
            'CONYUGE' TIPO,
            CONINT.IDENTIFICADOR IDENTIFICADOR_REPORTE,
            WFP.IDPROCESS,
            CASE WHEN CONINT.APELLIDOMCONYUG <> '' THEN CONINT.APELLIDOPCONYUG || ' ' || CONINT.APELLIDOMCONYUG || ' ' || CONINT.NOMBRECONYUGE 
        	ELSE CONINT.APELLIDOPCONYUG || ' ' || CONINT.NOMBRECONYUGE
            END NOMBRE_RS,
            CASE WHEN CONINT.RUTCONYUGE <> '' THEN CONINT.RUTCONYUGE ELSE CONINT.PASAPORTECONYUG END RUT,
            'Conyuge' RELACION_POSICION,
            '' CARGO,
            '' NOMBRE_EMPRESA,
            '' RUT_EMPRESA,
            
            CASE WHEN CONINT.FECHAMATRIMONIO IS NULL THEN NULL
            	 WHEN CONINT.FECHAMATRIMONIO < CONINT.FECHAINGRESO THEN CONINT.FECHAINGRESO 
            	 ELSE CONINT.FECHAMATRIMONIO 
           	END FECHA_INICIO_RP, 
		 /**CASE WHEN CONINT.FECHAMATRIMONIO IS NULL THEN NULL
            	 WHEN CONINT.FECHAMATRIMONIO < CONINT.FECHAINGRESO THEN DATEADD(day,1,CONINT.fechaingreso)
            	 ELSE DATEADD(day,1,CONINT.FECHAMATRIMONIO) 
           	END FECHA_INICIO_RP, **/
            CASE WHEN CONINT.fechaterminoauc IS NOT NULL then CONINT.fechaterminoauc ELSE CONINT.fechatermino END FECHA_TERMINO_RP,
            /**CONINT.APELLIDOP || ' ' || CONINT.APELLIDOM || ' ' || CONINT.NOMBRES NOMBRE_PR_O_CON_INFOR,**/
            CASE WHEN CONINT.APELLIDOM <> '' THEN CONINT.APELLIDOP || ' ' || CONINT.APELLIDOM || ' ' || CONINT.NOMBRES 
            ELSE CONINT.APELLIDOP || ' ' || CONINT.NOMBRES
            END NOMBRE_PR_O_CON_INFOR,
            CONINT.IDENTIFICADOR RUT_PR_O_CON_INFOR,
            '' NR,
            CAST(NULL AS NUMERIC) PORC_PARTICIPACION,
            '' NOMBRE_SOC_INTERMED,
            '' RUT_SOC_INTERMED,
            CAST(NULL AS DATE) FECHA_CONSTITUCION_SOCIE,
            1 CANTIDAD,
            TIPOPERSONA.PERSONA TIPO_PERSONA   
        FROM
            WFPROCESS WFP 
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID
        LEFT OUTER JOIN 
            DYNFORMPERSONA TIPOPERSONA
                ON TIPOPERSONA.OID = CONINT.OIDABC00JGS4Y3SN89  
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL=7
            --AND WFP.CDPROCESSMODEL=34
            AND TIPOPERSONA.IDPERSONA = 'GP-S'
            AND CONINT.CASADO = 1
            AND ( 
                (  CONINT.fechatermino IS NULL AND CONINT.fechaterminoauc IS NULL ) OR
                (  CONINT.fechaterminoauc IS NOT NULL AND CONINT.fechaterminoauc + interval '1 year' >= current_date ) OR
                (  CONINT.fechaterminoauc IS NULL AND CONINT.fechatermino IS NOT NULL AND CONINT.fechatermino + interval '1 year' >= current_date ) 
                )
        UNION
        SELECT
            '3' ORDEN,
            'SOCIEDADES DIRECTAS PERSONA SUJETA' TIPO,
            CONINT.IDENTIFICADOR IDENTIFICADOR_REPORTE,
            WFP.IDPROCESS,
            DIRECTA1A.RAZONSOCIAL NOMBRE_RS,
            DIRECTA1A.RUTEMPRESA RUT,
            RELACION.CARGO RELACION_POSICION,
            '' CARGO,
            '' NOMBRE_EMPRESA,
            '' RUT_EMPRESA,
            CASE WHEN DIRECTA1A.fechaconstituci IS NULL THEN NULL 
            	 WHEN DIRECTA1A.fechaconstituci < CONINT.FECHAINGRESO THEN CONINT.FECHAINGRESO 
            	 ELSE DIRECTA1A.fechaconstituci 
            END FECHA_INICIO_RP, 
		 	/**CASE WHEN DIRECTA1A.fechaconstituci IS NULL THEN NULL 
            	 WHEN DIRECTA1A.fechaconstituci < CONINT.FECHAINGRESO THEN DATEADD(day,1,CONINT.FECHAINGRESO) 
            	 ELSE DATEADD(day,1,DIRECTA1A.fechaconstituci)  
            END FECHA_INICIO_RP, **/
            CASE WHEN DIRECTA1A.fechaterminosoc IS NOT NULL THEN DIRECTA1A.fechaterminosoc ELSE CONINT.fechatermino END FECHA_TERMINO_RP,
            CASE WHEN CONINT.APELLIDOM <> '' THEN CONINT.APELLIDOP || ' ' || CONINT.APELLIDOM || ' ' || CONINT.NOMBRES 
        	ELSE CONINT.APELLIDOP || ' ' || CONINT.NOMBRES
            END NOMBRE_PR_O_CON_INFOR,
            CONINT.IDENTIFICADOR RUT_PR_O_CON_INFOR,
            'D' NR,
            CASE WHEN DIRECTA1A.dcparticipaciod = 0 THEN CAST(NULL AS NUMERIC) ELSE DIRECTA1A.dcparticipaciod END PORC_PARTICIPACION,
            '' NOMBRE_SOC_INTERMED,
            '' RUT_SOC_INTERMED,
            DIRECTA1A.FECHACONSTITUCI FECHA_CONSTITUCION_SOCIE,
            1 CANTIDAD,
            TIPOPERSONA.PERSONA TIPO_PERSONA        
        FROM
            WFPROCESS WFP 
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID  
        LEFT OUTER JOIN
            DYNFORMCARGO RELACION 
                ON RELACION.OID = CONINT.OIDABCE0RCAPNY60DK 
        INNER JOIN
            DYNgriddirecta DIRECTA1A 
                ON CONINT.OID = DIRECTA1A.OIDABCOU2ADJX2BYLK       
        LEFT OUTER JOIN 
            DYNFORMPERSONA TIPOPERSONA
                ON TIPOPERSONA.OID = CONINT.OIDABC00JGS4Y3SN89                                                               
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL=7
            --AND WFP.CDPROCESSMODEL=34
            AND TIPOPERSONA.IDPERSONA = 'GP-S'
            AND ( 
                (  CONINT.fechatermino IS NULL AND DIRECTA1A.fechaterminosoc IS NULL ) OR
                (  DIRECTA1A.fechaterminosoc IS NOT NULL AND DIRECTA1A.fechaterminosoc + interval '1 year' >= current_date ) OR
                (  DIRECTA1A.fechaterminosoc IS NULL AND CONINT.fechatermino IS NOT NULL AND CONINT.fechatermino + interval '1 year' >= current_date ) 
                ) 
        UNION
        SELECT
            '4' ORDEN,
            'SOCIEDADES INDIRECTAS PERSONA SUJETA' TIPO,
            CONINT.IDENTIFICADOR IDENTIFICADOR_REPORTE,
            WFP.IDPROCESS,
            INDIRECTA1A.RAZONSOCIALINDI NOMBRE_RS,
            INDIRECTA1A.RUTEMPRESAIND RUT,
            RELACION.CARGO RELACION_POSICION,
            '' CARGO,
            '' NOMBRE_EMPRESA,
            '' RUT_EMPRESA,
            CASE WHEN INDIRECTA1A.fechaindirecta IS NULL THEN NULL 
            	 WHEN INDIRECTA1A.fechaindirecta < CONINT.FECHAINGRESO THEN CONINT.FECHAINGRESO 
            	 ELSE INDIRECTA1A.fechaindirecta 
            END FECHA_INICIO_RP,
		 /**CASE WHEN INDIRECTA1A.fechaindirecta IS NULL THEN NULL 
            	 WHEN INDIRECTA1A.fechaindirecta < CONINT.FECHAINGRESO THEN DATEADD(day,1,CONINT.FECHAINGRESO) 
            	 ELSE DATEADD(day,1,INDIRECTA1A.fechaindirecta) 
            END FECHA_INICIO_RP,**/
            CASE WHEN INDIRECTA1A.fechatermisocin IS NOT NULL THEN INDIRECTA1A.fechatermisocin ELSE CONINT.fechatermino END FECHA_TERMINO_RP,
            CASE WHEN CONINT.APELLIDOM <> '' THEN CONINT.APELLIDOP || ' ' || CONINT.APELLIDOM || ' ' || CONINT.NOMBRES 
        	ELSE CONINT.APELLIDOP || ' ' || CONINT.NOMBRES
            END NOMBRE_PR_O_CON_INFOR,
            CONINT.IDENTIFICADOR RUT_PR_O_CON_INFOR,
            'I' NR,
            CASE WHEN INDIRECTA1A.dcpartipacioind = 0 THEN CAST(NULL AS NUMERIC) ELSE INDIRECTA1A.dcpartipacioind END PORC_PARTICIPACION,
            INDIRECTA1A.NOMSOCINTERMED NOMBRE_SOC_INTERMED,
            INDIRECTA1A.RUTSOCINTERMED RUT_SOC_INTERMED,
            INDIRECTA1A.FECHAINDIRECTA FECHA_CONSTITUCION_SOCIE,
            1 CANTIDAD,
            TIPOPERSONA.PERSONA TIPO_PERSONA      
        FROM
            WFPROCESS WFP 
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID  
        LEFT OUTER JOIN
            DYNFORMCARGO RELACION 
                ON RELACION.OID = CONINT.OIDABCE0RCAPNY60DK 
        INNER JOIN
            DYNgridindirecta INDIRECTA1A 
                ON CONINT.OID = INDIRECTA1A.OIDABCQS77FJTDKNWI    
        LEFT OUTER JOIN 
            DYNFORMPERSONA TIPOPERSONA
                ON TIPOPERSONA.OID = CONINT.OIDABC00JGS4Y3SN89                                                                  
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL=7
            --AND WFP.CDPROCESSMODEL=34
            AND TIPOPERSONA.IDPERSONA = 'GP-S' 
            AND ( 
                (  CONINT.fechatermino IS NULL AND INDIRECTA1A.fechatermisocin IS NULL ) OR
                (  INDIRECTA1A.fechatermisocin IS NOT NULL AND INDIRECTA1A.fechatermisocin + interval '1 year' >= current_date ) OR
                (  INDIRECTA1A.fechatermisocin IS NULL AND CONINT.fechatermino IS NOT NULL AND CONINT.fechatermino + interval '1 year' >= current_date ) 
                )
        UNION
        SELECT
            '5' ORDEN,
            'SOCIEDADES DIRECTAS CONYUGE' TIPO,
            CONINT.IDENTIFICADOR IDENTIFICADOR_REPORTE,
            WFP.IDPROCESS,
            DIRECTA1B.RAZONSOCIAL NOMBRE_RS,
            DIRECTA1B.RUTEMPRESA RUT,
            'Conyuge' RELACION_POSICION,
            '' CARGO,
            '' NOMBRE_EMPRESA,
            '' RUT_EMPRESA,
		 	CASE WHEN CONINT.FECHAMATRIMONIO IS NULL THEN NULL
                 WHEN DIRECTA1B.fechaconstituci IS NULL AND CONINT.FECHAMATRIMONIO IS NULL THEN NULL 
                 WHEN CONINT.FECHAINGRESO >= CONINT.FECHAMATRIMONIO AND CONINT.FECHAINGRESO >= DIRECTA1B.fechaconstituci THEN CONINT.FECHAINGRESO
                 WHEN CONINT.FECHAMATRIMONIO >= CONINT.FECHAINGRESO AND CONINT.FECHAMATRIMONIO >= DIRECTA1B.fechaconstituci THEN CONINT.FECHAMATRIMONIO
                 WHEN DIRECTA1B.fechaconstituci >= CONINT.FECHAINGRESO AND DIRECTA1B.fechaconstituci >= CONINT.FECHAMATRIMONIO THEN DIRECTA1B.fechaconstituci
            END FECHA_INICIO_RP,
            CASE WHEN DIRECTA1B.fechaterminosoc IS NOT NULL THEN DIRECTA1B.fechaterminosoc ELSE CASE WHEN CONINT.fechaterminoauc IS NOT NULL THEN CONINT.fechaterminoauc ELSE CONINT.fechatermino END END FECHA_TERMINO_RP,
            CASE WHEN CONINT.APELLIDOMCONYUG <> '' THEN CONINT.APELLIDOPCONYUG || ' ' || CONINT.APELLIDOMCONYUG || ' ' || CONINT.NOMBRECONYUGE 
        	ELSE CONINT.APELLIDOPCONYUG || ' ' || CONINT.NOMBRECONYUGE
            END NOMBRE_PR_O_CON_INFOR,
            CASE WHEN CONINT.RUTCONYUGE <> '' THEN CONINT.RUTCONYUGE ELSE CONINT.PASAPORTECONYUG END  RUT_PR_O_CON_INFOR,
            'D' NR,
            CASE WHEN DIRECTA1B.dcparticipaciod = 0 THEN CAST(NULL AS NUMERIC) ELSE DIRECTA1B.dcparticipaciod END PORC_PARTICIPACION,
            '' NOMBRE_SOC_INTERMED,
            '' RUT_SOC_INTERMED,
            DIRECTA1B.FECHACONSTITUCI FECHA_CONSTITUCION_SOCIE,
            1 CANTIDAD,
            TIPOPERSONA.PERSONA TIPO_PERSONA       
        FROM
            WFPROCESS WFP 
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID  
        INNER JOIN
            DYNgriddirecta DIRECTA1B 
                ON CONINT.OID = DIRECTA1B.OIDABCVYS8QF6JTCMG    
        LEFT OUTER JOIN 
            DYNFORMPERSONA TIPOPERSONA
                ON TIPOPERSONA.OID = CONINT.OIDABC00JGS4Y3SN89                                                                  
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL=7
            --AND WFP.CDPROCESSMODEL=34
            AND TIPOPERSONA.IDPERSONA = 'GP-S'
            AND ( 
                (  CONINT.fechatermino IS NULL AND CONINT.fechaterminoauc IS NULL AND DIRECTA1B.fechaterminosoc IS NULL) OR
                (  DIRECTA1B.fechaterminosoc IS NOT NULL AND DIRECTA1B.fechaterminosoc + interval '1 year' >= current_date ) OR
                (  DIRECTA1B.fechaterminosoc IS NULL AND CONINT.fechaterminoauc IS NOT NULL AND CONINT.fechaterminoauc + interval '1 year' >= current_date ) OR
                (  DIRECTA1B.fechaterminosoc IS NULL AND CONINT.fechaterminoauc IS NULL AND CONINT.fechatermino IS NOT NULL AND CONINT.fechatermino + interval '1 year' >= current_date )
                ) 
        UNION
        SELECT
            '6' ORDEN,
            'SOCIEDADES INDIRECTAS CONYUGE' TIPO,
            CONINT.IDENTIFICADOR IDENTIFICADOR_REPORTE,
            WFP.IDPROCESS,
            INDIRECTA1B.RAZONSOCIALINDI NOMBRE_RS,
            INDIRECTA1B.RUTEMPRESAIND RUT,
            'Conyuge' RELACION_POSICION,
            '' CARGO,
            '' NOMBRE_EMPRESA,
            '' RUT_EMPRESA,
            CASE WHEN CONINT.FECHAMATRIMONIO IS NULL THEN NULL
            	 WHEN INDIRECTA1B.fechaindirecta IS NULL AND CONINT.FECHAMATRIMONIO IS NULL THEN NULL 
                 WHEN CONINT.FECHAINGRESO >= CONINT.FECHAMATRIMONIO AND CONINT.FECHAINGRESO >= INDIRECTA1B.fechaindirecta THEN CONINT.FECHAINGRESO
                 WHEN CONINT.FECHAMATRIMONIO >= CONINT.FECHAINGRESO AND CONINT.FECHAMATRIMONIO >= INDIRECTA1B.fechaindirecta THEN CONINT.FECHAMATRIMONIO
                 WHEN INDIRECTA1B.fechaindirecta >= CONINT.FECHAINGRESO AND INDIRECTA1B.fechaindirecta >= CONINT.FECHAMATRIMONIO THEN INDIRECTA1B.fechaindirecta 
            END FECHA_INICIO_RP,
            CASE WHEN INDIRECTA1B.fechatermisocin IS NOT NULL THEN INDIRECTA1B.fechatermisocin ELSE CASE WHEN CONINT.fechaterminoauc IS NOT NULL THEN CONINT.fechaterminoauc ELSE CONINT.fechatermino END END FECHA_TERMINO_RP,
            CASE WHEN CONINT.APELLIDOMCONYUG <> '' THEN CONINT.APELLIDOPCONYUG || ' ' || CONINT.APELLIDOMCONYUG || ' ' || CONINT.NOMBRECONYUGE 
        	ELSE CONINT.APELLIDOPCONYUG || ' ' || CONINT.NOMBRECONYUGE
            END NOMBRE_PR_O_CON_INFOR,
            CASE WHEN CONINT.RUTCONYUGE <> '' THEN CONINT.RUTCONYUGE ELSE CONINT.PASAPORTECONYUG END  RUT_PR_O_CON_INFOR,
            'I' NR,
            CASE WHEN INDIRECTA1B.dcpartipacioind = 0 THEN CAST(NULL AS NUMERIC) ELSE INDIRECTA1B.dcpartipacioind END PORC_PARTICIPACION,
            INDIRECTA1B.NOMSOCINTERMED NOMBRE_SOC_INTERMED,
            INDIRECTA1B.RUTSOCINTERMED RUT_SOC_INTERMED,
            INDIRECTA1B.FECHAINDIRECTA FECHA_CONSTITUCION_SOCIE,
            1 CANTIDAD,
            TIPOPERSONA.PERSONA TIPO_PERSONA               
        FROM
            WFPROCESS WFP 
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID  
        INNER JOIN
            DYNgridindirecta INDIRECTA1B 
                ON CONINT.OID = INDIRECTA1B.OIDABCYJGWYLDQPSXY  
        LEFT OUTER JOIN 
            DYNFORMPERSONA TIPOPERSONA
                ON TIPOPERSONA.OID = CONINT.OIDABC00JGS4Y3SN89                                                                    
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL=7
            --AND WFP.CDPROCESSMODEL=34
            AND TIPOPERSONA.IDPERSONA = 'GP-S'
            AND ( 
                (  CONINT.fechatermino IS NULL AND CONINT.fechaterminoauc IS NULL AND INDIRECTA1B.fechatermisocin IS NULL) OR
                (  INDIRECTA1B.fechatermisocin IS NOT NULL AND INDIRECTA1B.fechatermisocin + interval '1 year' >= current_date ) OR
                (  INDIRECTA1B.fechatermisocin IS NULL AND CONINT.fechaterminoauc IS NOT NULL AND CONINT.fechaterminoauc + interval '1 year' >= current_date ) OR
                (  INDIRECTA1B.fechatermisocin IS NULL AND CONINT.fechaterminoauc IS NULL AND CONINT.fechatermino IS NOT NULL AND CONINT.fechatermino + interval '1 year' >= current_date )
                )
    ) REP 