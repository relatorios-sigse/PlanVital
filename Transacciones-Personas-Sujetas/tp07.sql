SELECT
        CASE  
            WHEN TRANTP07.Quien_Hace_Transaccion = 'SOCIEDAD' 
            OR TRANTP07.Quien_Hace_Transaccion = 'CONYUGE' THEN TRANTP07.Nombre_Razon_Social 
            ELSE  CASE 
                WHEN NOMBAPELL.APELLIDO_MATERNO <> '' THEN NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.APELLIDO_MATERNO || ' ' || NOMBAPELL.NOMBRE 
                ELSE NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.NOMBRE 
            END 
        END APELLIDOS_NOMBRES,
        REPLACE(TRANTP07.Rut_Nacional, '-','') Rut_Nacional_SinGuion,
        REPLACE(TRANTP07.Rut_Extranjero, '-','') Rut_Extranjero_SinGuion,
        REPLACE(TRANTP07.Identificador, '-','') Identificador_SinGuion,
        TRANTP07.* 
    FROM
        (SELECT
            WFP.idprocess AS Id_Workflow,
            TP07.unidades AS Unidades,
            TP07.tipocamb AS Tipo_de_Cambio,
            TP07.valotota AS Valor_total,
            MONCOM.codimone AS Moneda_de_Compra,
            MONVEN.codimone AS Moneda_de_Venta,
            TP07.fechatransaccio AS Fecha_de_Transacción,
            TO_CHAR(TP07.fechatransaccio,'YYYYMMDD') AS Fecha_de_Transaccion_Mod,
            TP07.contraparte AS Contraparte,
            TRIM(regexp_replace(TP07.nombrefinal,
            '\s+',
            ' ',
            'g')) AS Nombre_Razon_Social,
            TP07.rutfinal AS Rut_Nacional,
            TP07.pasaportefinal AS Rut_Extranjero,
            PAIS.pais AS Pais,
            CASE 
                WHEN TP07.pasaportefinal IS NULL THEN TRIM(TP07.rutfinal) 
                ELSE TRIM(TP07.pasaportefinal) 
            END Identificador,
            USUA.usuariotransacc Quien_Hace_Transaccion,
            CONINT.nombres Nombre_Completo_PS,
            1 AS Cantidad               
        FROM
            WFPROCESS WFP          
        INNER JOIN
            GNASSOCFORMREG FORMREG                  
                ON FORMREG.CDASSOC=WFP.CDASSOCREG          
        INNER JOIN
            DYNci CONINT                  
                ON FORMREG.OIDENTITYREG=CONINT.OID           
        INNER JOIN
            DYNgridtp07 TP07                  
                ON CONINT.OID = TP07.OIDABCGNTGWD1P2VL6                        
        LEFT JOIN
            DYNformmone MONCOM                  
                ON MONCOM.OID = TP07.OIDABCXPBIRV121Q4B     
        LEFT JOIN
            DYNformmone MONVEN                  
                ON MONVEN.OID = TP07.OIDABCPQNQO5W8Q2LL         
        LEFT JOIN
            DYNformpais PAIS                  
                ON PAIS.OID = TP07.OIDABCIGEYWJF2KB29             
        LEFT JOIN
            DYNformusrtran USUA 
                ON USUA.OID = TP07.OIDABCYO7L157405FE                                                                      
        WHERE
            WFP.FGSTATUS <= 5              
            AND WFP.CDPROCESSMODEL=42) TRANTP07 
    LEFT JOIN
        (
            SELECT
                DISTINCT CASE 
                    WHEN CONINT.NPASAPORTE IS NULL THEN TRIM(CONINT.RUT) 
                    ELSE TRIM(CONINT.NPASAPORTE) 
                END IDENTIFICADOR,
                trim(CONINT.NOMBRES) NOMBRE,
                trim(CONINT.APELLIDOP) APELLIDO_PATERNO,
                trim(CONINT.APELLIDOM) APELLIDO_MATERNO 
            FROM
                WFPROCESS WFP  
            LEFT OUTER JOIN
                GNASSOCFORMREG FORMREG 
                    ON FORMREG.CDASSOC=WFP.CDASSOCREG 
            INNER JOIN
                DYNci CONINT 
                    ON FORMREG.OIDENTITYREG=CONINT.OID 
            WHERE
                WFP.FGSTATUS <= 5 
                AND WFP.CDPROCESSMODEL = 7
        ) NOMBAPELL 
            ON NOMBAPELL.IDENTIFICADOR = TRANTP07.IDENTIFICADOR