SELECT
        CASE               
            WHEN TRANTP04.Quien_Hace_Transaccion = 'SOCIEDAD'              
            OR TRANTP04.Quien_Hace_Transaccion = 'CONYUGE' THEN TRANTP04.Nombre_Razon_Social              
            ELSE  CASE                  
                WHEN NOMBAPELL.APELLIDO_MATERNO <> '' THEN NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.APELLIDO_MATERNO || ' ' || NOMBAPELL.NOMBRE                  
                ELSE NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.NOMBRE              
            END          
        END APELLIDOS_NOMBRES,
        TRANTP04.*      
    FROM
        (SELECT
            WFP.idprocess AS Id_Workflow,
            TP04.foliotransaccio AS Folio_de_Transaccion,
            INST.tipoinst AS Tipo_de_Instrumento,
            TP04.instobje AS Instrumento_Objeto,
            TP04.nemotecnico AS Nemotecnico_del_Instrumento,
            TP04.precejercont AS Precio_de_Ejercicio_Contrato,
            TP04.precejerorig AS Precio_de_ejecrcicio_Original,
            TP04.unidades AS Unidades,
            TP04.unidmoneobje AS Unidades_moneda_objeto,
            TP04.precunit AS Precio_Unitario,
            TP04.valortotal AS Valor_total,
            CASE      
                WHEN TP04.compraventa  = 'C'     THEN 'COMPRA'          
                WHEN TP04.compraventa = 'V'     THEN 'VENTA'          
                ELSE ''  
            END AS Tipo_de_Movimiento,
            TP04.nombreemisor AS Administrador_de_cartera,
            TP04.tipooper AS Tipo_de_Operacion,
            TP04.acticubi AS Activo_Cubierto,
            TP04.agenliqubols AS Agente_Liquidador_Bolsa,
            TP04.tipoopci AS Tipo_de_Opción,
            TP04.fechatransaccio AS Fecha_de_Transaccion,
            TO_CHAR(TP04.fechatransaccio,
            'YYYY-MM-DD') AS Fecha_de_Transaccion_Mod,
            TRIM(regexp_replace(TP04.nombrefinal,
            '\s+',
            ' ',
            'g')) AS Nombre_Razon_Social,
            TP04.rutfinal AS Rut_Nacional,
            TP04.pasaportefinal AS Rut_Extranjero,
            PAIS.pais AS Pais,
            CASE                  
                WHEN TP04.pasaportefinal IS NULL THEN TRIM(TP04.rutfinal)                  
                ELSE TRIM(TP04.pasaportefinal)              
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
            DYNgridtp04 TP04                                   
                ON CONINT.OID = TP04.OIDABCDL2K10P7CG0V                   
        LEFT JOIN
            DYNforminst INST                                   
                ON INST.OID = TP04.OIDABCXF9PG4R1M0G4          
        LEFT JOIN
            DYNformpais PAIS                 
                ON PAIS.OID = TP04.OIDABCXNX6S349O81E                                         
        LEFT JOIN
            DYNformusrtran USUA                  
                ON USUA.OID = TP04.OIDABCX249ULADPC5A                                                                               
        WHERE
            WFP.FGSTATUS <= 5                           
            AND WFP.CDPROCESSMODEL=42) TRANTP04     
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
            ON NOMBAPELL.IDENTIFICADOR = TRANTP04.IDENTIFICADOR 