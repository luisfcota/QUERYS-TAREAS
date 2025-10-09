----------------ID CON VERIINE NO VIGENTE, REPORTE DE ROBO Y REPORTE DE EXTRAVIO 
SELECT
    DISTINCT _id,
    fecha_ultima_modificacion,
    task AS resultado_task 
FROM
    `personas-findep.DIGITAL.me_solicitudes`,
    UNNEST(JSON_QUERY_ARRAY(roadmap)) AS task
WHERE
    UPPER(TRIM(JSON_VALUE(task, '$.payload.response.dataResponse.respuestaSituacionRegistral.tipoSituacionRegistral'))) = 'NO_VIGENTE' 
    --UPPER(TRIM(JSON_VALUE(task, '$.payload.response.dataResponse.respuestaSituacionRegistral.tipoReporteRoboExtravio'))) = 'REPORTE_DE_EXTRAVIO_TEMPORAL' 
    --UPPER(TRIM(JSON_VALUE(task, '$.payload.response.dataResponse.respuestaSituacionRegistral.tipoReporteRoboExtravio'))) = 'REPORTE_DE_ROBO_TEMPORAL'
    UPPER(TRIM(JSON_VALUE(task, '$.taskId'))) = 'VERIINE'  
    AND UPPER(TRIM(JSON_VALUE(task, '$.result'))) = 'APPROVED'
    AND DATE(fecha_ultima_modificacion) >= '2025-08-01'

------------------ID SIN PAQUETE
SELECT
    DISTINCT _id,
    fecha_ultima_modificacion,
    task AS resultado_task 
FROM
    `personas-findep.DIGITAL.me_solicitudes`,
    UNNEST(JSON_QUERY_ARRAY(roadmap)) AS task
WHERE      
    UPPER(TRIM(JSON_VALUE(task, '$.taskId'))) = 'AXIPAQUETEPOST'
    AND UPPER(TRIM(JSON_VALUE(task, '$.result'))) = 'ERROR'
    AND DATE(fecha_ultima_modificacion) >= '2025-08-01'

--------------ID CON COMPROBANTE DE DOMICILIO NO VALIDO
SELECT
    DISTINCT _id,
    fecha_ultima_modificacion,
    task AS resultado_task 
FROM
    `personas-findep.DIGITAL.me_solicitudes`,
    UNNEST(JSON_QUERY_ARRAY(roadmap)) AS task
WHERE 
    UPPER(TRIM(JSON_VALUE(task, '$.taskId'))) = "DOMDIGITAL"
    AND UPPER(TRIM(JSON_VALUE(task, '$.result'))) = 'APPROVED'
    AND UPPER(TRIM(JSON_VALUE(task, '$.statusDescription'))) = "VALIDACION DOM PARTICULAR DOCUMENTO NO ES VALIDO"
    AND DATE(fecha_ultima_modificacion) >= '2025-08-01'

-------------------VALORES UNICOS EN TAREAS (CUALQUIER TAREA)
SELECT
    DISTINCT
    UPPER(TRIM(JSON_VALUE(task, '$.statusDescription'))) AS statusDescription
FROM
    `personas-findep.DIGITAL.me_solicitudes`,
    UNNEST(JSON_QUERY_ARRAY(roadmap)) AS task
WHERE
    UPPER(TRIM(JSON_VALUE(task, '$.taskId'))) = 'DOMDIGITAL'
    AND UPPER(TRIM(JSON_VALUE(task, '$.result'))) = 'APPROVED'

----------------------COMPORTAMIENTO EN INE NO VALIDAS

SELECT
    DISTINCT _id,
    fecha_ultima_modificacion,
    task AS resultado_task 
FROM
    `personas-findep.DIGITAL.me_solicitudes`,
    UNNEST(JSON_QUERY_ARRAY(roadmap)) AS task

WHERE 
    UPPER(TRIM(JSON_VALUE(task, '$.taskId'))) = 'AXIINEML'
    AND UPPER(TRIM(JSON_VALUE(task, '$.result'))) = 'REJECTED'
    AND JSON_VALUE(task, '$.payload.mensaje') LIKE '%Error al validar INE: could not execute statement%'
    AND DATE(fecha_ultima_modificacion) >= '2025-08-01'

------------------------COUNT TAREAS VERIINE POR ID

SELECT
    _id,
    fecha_ultima_modificacion,
    task AS resultado_task,
    COUNTIF(UPPER(TRIM(JSON_VALUE(task, '$.taskId'))) = 'VERIINE')   
        OVER (PARTITION BY _id) AS total_veriine_por_id
FROM
    `personas-findep.DIGITAL.me_solicitudes`,
    UNNEST(JSON_QUERY_ARRAY(roadmap)) AS task
WHERE
    UPPER(TRIM(JSON_VALUE(task, '$.payload.response.dataResponse.respuestaSituacionRegistral.tipoSituacionRegistral'))) = 'NO_VIGENTE'
    AND UPPER(TRIM(JSON_VALUE(task, '$.taskId'))) = 'VERIINE'  
    AND UPPER(TRIM(JSON_VALUE(task, '$.result'))) = 'APPROVED'
    AND DATE(fecha_ultima_modificacion) >= '2025-08-01'
    
    ORDER BY total_veriine_por_id DESC

---------------------- seguro de vida duplicados en transacciones

SELECT _id, roadmap, status
FROM personas-findep.DIGITAL.me_solicitudes

WHERE status = "COMPLETED"

  AND UPPER(TRIM(JSON_VALUE(roadmap, '$.taskId'))) = 'VERIDIGITALIZACIONEXPEDIENTE'
  AND UPPER(TRIM(JSON_VALUE(roadmap, '$.payload.checklist.name'))) = 'Seguro de Vida'
  
    AND DATE(fecha_ultima_modificacion) >= '2025-08-01'

    

