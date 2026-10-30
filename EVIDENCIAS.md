# Evidencias — Tipo de examen: 3

## Ítem 1 — Consentimiento

Explicación técnica: Consentimiento es un modelo inmutable que reúne las dos opciones, la versión y la fecha. ConsentimientoRepository define lectura y escritura sin depender de la interfaz gráfica. PreferenciasConsentimientoRepository implementa esa interfaz con SharedPreferences y JSON. ConsentimientoViewModel recibe el repositorio por constructor, usa false si no existe una decisión y publica una nueva decisión solamente después de guardarla correctamente. PrivacidadView mantiene la selección provisional hasta pulsar Aceptar o Rechazar. MainApp elige entre esa pantalla y HomeView; la autenticación existente conserva sus clases y su sesión.

Capturas de app:
1. Primera apertura: título Privacidad, ambos interruptores apagados y botones iguales.
2. Activar solamente Analítica de uso y pulsar Aceptar: aparece el inicio con instalaciones reales.
3. Abrir Perfil > Privacidad: solamente Analítica sigue encendida y se muestra la fecha de la última decisión.
4. Pulsar Rechazar, volver a abrir Privacidad y comprobar ambos interruptores apagados.
5. Cerrar y abrir la app: se conserva la decisión y entra al inicio.
6. Repetir acceso a Privacidad desde el perfil con y sin sesión cuando dispongas de una cuenta de prueba.

No es necesario borrar los datos de la app: si ya existe una decisión, usa Perfil > Privacidad para revisar y cambiarla. La captura de primera apertura debe hacerse en una instalación sin decisión previa.

Capturas de código (rutas relativas a gameon_mobile):
- `lib/features/privacidad/models/consentimiento.dart`: versionActual, toJson y fecha.toUtc().toIso8601String().
- `lib/features/privacidad/repositories/consentimiento_repository.dart`: interfaz y la escritura en una sola clave.
- `lib/features/privacidad/viewmodels/consentimiento_viewmodel.dart`: constructor inyectado, getters con false, guardar y manejo del fallo de almacenamiento.
- `lib/features/privacidad/views/privacidad_view.dart`: SwitchListTile, botones OutlinedButton dentro de Expanded y _guardar(false).
- `lib/main.dart`: creación del repositorio, Provider y selección de home.
- Vistas del perfil autenticado y no autenticado: opción Privacidad.

Para obtener las líneas exactas a resaltar desde la raíz del repositorio:

```powershell
rg -n 'versionActual|toIso8601String|abstract interface|setString|ConsentimientoViewModel\(|get analitica|get promociones|Future<bool> guardar|SwitchListTile|OutlinedButton|PrivacidadView|tieneDecision' gameon_mobile/lib/features/privacidad gameon_mobile/lib/main.dart gameon_mobile/lib/features/perfil/views/perfil_view
```

Terminal (desde la raíz del repositorio; abre una terminal nueva si Flutter aún no aparece en el PATH):

```powershell
cd gameon_mobile
flutter test test/features/privacidad/consentimiento_test.dart
flutter test
flutter analyze lib/features/privacidad lib/main.dart
flutter devices
flutter run -d emulator-5556
```

El identificador puede cambiar; usa el Android de 64 bits listado por flutter devices.

Resultados ejecutados: suite completa con 47 pruebas correctas; análisis de privacidad y main sin problemas. Las cinco nuevas pruebas cubren valores iniciales, aceptación selectiva, fallo de escritura, persistencia del rechazo/versión/fecha y reapertura con rechazo desde la pantalla.

El consentimiento promocional se guarda por separado de los permisos del sistema operativo. No se agregó todavía un servicio de analítica ni una campaña promocional: el control de eventos corresponde al ítem 3.

## Ítems 4 y 5 completados
## Ítem 2 — Petición mínima al guardar el perfil

Petición real: actualización de usuarios_deportistas desde EditPerfilViewModel.upsertUsuarioDeportista. El formulario crea la entidad con sus valores editados; GuardarPerfilRequest.fromUsuario convierte esa entidad a un DTO independiente y toJson enumera exclusivamente los campos editables. El cuerpo usado por update(payload) sale de ese DTO.

### Tabla de minimización

| Campo de UsuarioDeportista | ¿Se envía en el cuerpo de actualización? | Por qué |
|---|---|---|
| id | No | Se usa en el filtro eq('id', id), no como columna modificable. |
| authId | No | La actualización no cambia el vínculo de autenticación. Si se crea el perfil, se añade auth_id desde la sesión, nunca desde la entidad. |
| username | Sí | Nombre de usuario editable y comprobación de duplicados. |
| nombre | Sí | Nombre mostrado en el perfil. |
| apellidos | Sí | Apellidos mostrados en el perfil. |
| telefono | Sí | Campo de contacto editable existente. |
| fechaNacimiento | Sí, puede ser null | Campo editable del perfil; se conserva el formato del flujo existente. |
| genero | Sí | Campo editable existente. |
| nivelHabilidad | Sí | Campo deportivo editable existente. |
| imagenPerfil | Solo si no está vacía | URL de la foto; no se adjuntan bytes en esta petición. |
| estado | No | No corresponde modificarlo desde este formulario. |
| createdAt | No | Fecha de creación ajena a la edición del usuario. |
| deportesFavoritos | No | Se guardan por la operación separada de usuarios_deportes. |

fcm_token no pertenece a esta entidad y se excluyó de la operación de edición: PerfilViewModel ya lo actualiza de manera independiente. El perfil no contiene coordenadas; no se agregan ni se envían latitud/longitud. Por ello el requisito de tres decimales no aplica a esta petición.

Verificación del contrato: el archivo bd/script_tablas/bd_30102026.md NO incluye usuarios_deportistas. Los campos conservados se basan en el modelo, formulario y petición existentes. No se ha verificado el esquema remoto ni las políticas RLS. La prueba local confirma la lista de campos, no la aceptación por el servidor. No se retiraron campos editables del negocio suponiendo que fueran innecesarios.

### Capturas de código

Rutas desde gameon_mobile:
- lib/features/perfil/models/guardar_perfil_request.dart: líneas 4–49, DTO, conversión y lista explícita de campos.
- lib/features/perfil/viewmodels/edit_perfil_viewmodel.dart: líneas 56–94, conversión, payload, update y auth_id tomado de sesión únicamente en el upsert.
- lib/features/perfil/views/perfil_view/authenticated/edit_perfil/edit_perfil_view.dart: alrededor de la línea 300, entidad construida con los datos reales del formulario.
- test/features/perfil/guardar_perfil_request_test.dart: lista exacta de claves permitidas y exclusión de metadatos y coordenadas.

### Captura del cuerpo enviado: inspector de red

1. Ejecuta la app en debug y abre Flutter DevTools con el enlace que muestra flutter run en la terminal.
2. Abre la pestaña Network e inicia la grabación antes de guardar.
3. Con una cuenta de prueba, entra a Perfil > Editar perfil y guarda una modificación de prueba.
4. Filtra por usuarios_deportistas y selecciona la solicitud PATCH (no el GET de comprobación del username).
5. Muestra el cuerpo JSON de la solicitud: debe contener solo las claves de la tabla anterior que corresponden al formulario.
6. Captura el código del DTO y el cuerpo de esa solicitud. Usa datos de prueba y no incluyas encabezados Authorization, cookies, tokens ni datos de personas reales.

Este procedimiento requiere que tú inicies sesión con tu cuenta de prueba. No se ejecutaron escrituras remotas ni se modificaron perfiles reales durante la implementación.

Si necesitas localizar las líneas con PowerShell, desde la raíz del repositorio:

```powershell
Get-Content gameon_mobile/lib/features/perfil/models/guardar_perfil_request.dart
Select-String -Path gameon_mobile/lib/features/perfil/viewmodels/edit_perfil_viewmodel.dart -Pattern 'fromUsuario|request.toJson|update\(payload|upsert\('
```

Pruebas, desde gameon_mobile:

```powershell
flutter test test/features/perfil/guardar_perfil_request_test.dart
flutter test
```

Resultados: las 2 pruebas del DTO pasan; 49 pruebas totales correctas. El análisis de los tres archivos no detectó errores; reportó 5 avisos informativos preexistentes sobre imports y uso de contexto tras await.
## Ítem 3 — Logs enmascarados y analítica con consentimiento

Explicación: PiiMasker aplica primero correo, después celular de nueve dígitos y finalmente DNI de ocho dígitos. Los límites de palabra evitan coincidencias parciales y que un celular se interprete como DNI. También oculta URLs completas, ya que las de fotos y pagos pueden contener tokens. Estas reglas cubren esos patrones; no equivalen a reconocer todos los posibles datos personales en texto libre.

AppLogger es el único punto de salida de los logs propios de lib: construye el mensaje con nombre, error y traza, enmascara todo y llama a debugPrint. Se reemplazaron las llamadas de 15 archivos de notificaciones, navegación, chat, inicio, mapa, perfil, correo, reservas y PayPal. Se eliminaron los console.log del JavaScript inyectado en la WebView. Los logs de Android, Flutter y SDK externos no son escritos por nuestro código y pueden seguir apareciendo.

AnalyticsService define el destino de eventos. LoggingAnalyticsService usa exclusivamente AppLogger. ConsentAwareAnalyticsService comprueba el ViewModel de consentimiento en cada llamada antes de invocar el destino. main.dart inyecta esta implementación mediante Provider. No se añadió una biblioteca externa de analítica ni se envían eventos a un servidor de analítica.

La acción real de guardar perfil, después de guardar sus deportes, llama a AppLogger con datos ficticios (no se guardan en el backend) y registra perfil_guardado mediante el servicio condicionado. La línea de diagnóstico no depende del consentimiento de analítica; el evento de analítica sí.

### Capturas de app y consola

1. En la terminal donde flutter run está activo, pulsa R mayúscula para reiniciar la app y cargar también el nuevo Provider. Si ya no está activo, ejecuta flutter run desde gameon_mobile.
2. En Perfil > Privacidad, deja apagada Analítica de uso y pulsa Aceptar.
3. En Perfil > Editar perfil, con la cuenta de prueba, guarda un perfil válido.
4. Captura en la terminal la línea:

```text
[GameOn] [PrivacidadDemo] cliente [CORREO] cel [CELULAR] dni [DNI]
```

5. Activa Analítica de uso en Privacidad, vuelve a guardar y captura además:

```text
[GameOn] [Analytics] evento=perfil_guardado
```

6. Retira Analítica, vuelve a guardar y comprueba que no aparece un nuevo evento Analytics. La prueba con analítica falsa confirma automáticamente esta condición, sin depender de observar ausencias en consola.

En Logcat usa el paquete com.nkmelndz.gameon y el filtro de texto GameOn, PrivacidadDemo o Analytics. En DevTools Logging busca esos mismos textos. Los logs anteriores de sesiones anteriores no se borran con esta implementación.

### Capturas de código

- lib/core/logging/pii_masker.dart: expresiones regulares, límites y orden de reemplazos.
- lib/core/logging/app_logger.dart: composición del mensaje, enmascarado y única salida.
- lib/core/services/analytics_service.dart: interfaz, implementación de log y condición antes de destino.track.
- lib/main.dart: Provider de AnalyticsService con el consentimiento compartido.
- lib/features/perfil/views/perfil_view/authenticated/edit_perfil/edit_perfil_view.dart: busca PrivacidadDemo y perfil_guardado para mostrar la acción real.
- test/core/privacy_logging_test.dart: texto de prueba, logger y destino falso después de retirar consentimiento.

### Búsqueda ejecutada

Desde gameon_mobile, con ripgrep disponible:

```powershell
rg -n '\b(print|debugPrint|debugPrintStack)\s*\(|\bdeveloper\.log\s*\(|\bconsole\.(log|warn|error|info|debug)\s*\(|\b(stdout|stderr)\.(write|writeln)\s*\(' lib -g '!app_logger.dart'
```

Salida: ninguna coincidencia (código 1 de rg significa que no encontró coincidencias).

Alternativa incluida en PowerShell, para tu captura sin instalar rg. Ejecuta desde gameon_mobile:

```powershell
$patron = '\b(print|debugPrint|debugPrintStack)\s*\(|\bdeveloper\.log\s*\(|\bconsole\.(log|warn|error|info|debug)\s*\(|\b(stdout|stderr)\.(write|writeln)\s*\('
$hallazgos = @(Get-ChildItem lib -Recurse -File -Filter '*.dart' | Where-Object { $_.Name -ne 'app_logger.dart' } | Select-String -Pattern $patron)
if ($hallazgos.Count -eq 0) { 'PASS: 0 escrituras directas al log fuera de AppLogger.' } else { $hallazgos }
```

Salida verificada:

```text
PASS: 0 escrituras directas al log fuera de AppLogger.
```

### Pruebas ejecutadas

Desde gameon_mobile:

```powershell
flutter test test/core/privacy_logging_test.dart
flutter test
flutter analyze lib/core/logging lib/core/services/analytics_service.dart
flutter build apk --debug
```

Resultados: 5 pruebas nuevas y 54 totales correctas; análisis de logger, masker y analítica sin problemas. El análisis global no detectó errores, pero mantiene avisos de mantenimiento existentes.
## Ítem 4 — Tres pruebas unitarias de consentimiento

Archivo: `gameon_mobile/test/examen_tipo3/item4_consentimiento_test.dart`.

Explicación técnica: FakeConsentimientoRepository guarda una decisión en memoria y FakeAnalytics recopila eventos en una lista. Se inyectan en las mismas clases que usa la app. Cada prueba recibe instancias nuevas mediante setUp, para que una aceptación anterior no afecte a otro escenario. Tras retirar analítica se usa el mismo servicio, verificando que no conserve indebidamente una autorización anterior. No se inicializan Firebase ni Supabase.

Captura de código: muestra las clases FakeConsentimientoRepository/FakeAnalytics y los tres bloques test con sus expect. Puedes usar varias imágenes si no caben de forma legible.

Captura de terminal: abre otra terminal si flutter run sigue activo. Ejecuta:

```powershell
cd C:\Users\HP\Documents\gaa\py_moviles_ii_capicodex\gameon_mobile
flutter test test/examen_tipo3/item4_consentimiento_test.dart --reporter expanded
```

Salida verificada (el tiempo puede variar):

```text
00:00 +0: ITEM 4(a) Sin decision: ambos usos apagados
00:00 +1: ITEM 4(b) Solo analitica: guarda seleccion y version 1.0
00:00 +2: ITEM 4(c) Retirar analitica bloquea el siguiente evento
00:00 +3: All tests passed!
```

Incluye el comando, los tres escenarios y All tests passed! en tu captura. No se necesita una captura del emulador para este ítem.

## Ítem 5 — Dos pruebas unitarias de enmascarado y envío mínimo

Archivo: `gameon_mobile/test/examen_tipo3/item5_enmascarado_envio_test.dart`.

Explicación técnica: el primer escenario invoca PiiMasker con el texto solicitado y verifica tanto el resultado enmascarado como la ausencia de los tres originales. El segundo construye UsuarioDeportista con metadatos, lo convierte con GuardarPerfilRequest.fromUsuario y comprueba el JSON serializado. Se exige el conjunto exacto de campos permitidos y se comprueba la ausencia de los excluidos. No se añaden coordenadas artificiales: esta entidad no las tiene, y se comprueba que no aparezcan en el cuerpo.

Captura de código: muestra el texto de prueba, los expect de ausencia y el bloque de conversión/JSON con los campos excluidos.

Captura de terminal:

```powershell
cd C:\Users\HP\Documents\gaa\py_moviles_ii_capicodex\gameon_mobile
flutter test test/examen_tipo3/item5_enmascarado_envio_test.dart --reporter expanded
```

Salida verificada:

```text
00:00 +0: ITEM 5(a) Enmascara correo, celular y DNI sin dejar originales
00:00 +1: ITEM 5(b) Entidad a peticion: excluye metadatos y no envia coordenadas
00:00 +2: All tests passed!
```

## Verificación final

```powershell
flutter test --reporter expanded
flutter analyze test/examen_tipo3 test/core/privacy_logging_test.dart test/features/perfil/guardar_perfil_request_test.dart test/features/privacidad/consentimiento_test.dart
```

Resultado final: 53 pruebas correctas y análisis de pruebas sin problemas. Los escenarios de examen se trasladaron de los archivos anteriores y se consolidaron dos comprobaciones iniciales; no se duplicaron. Los conteos y comandos de los apartados anteriores documentan etapas previas; para las capturas de los ítems 4 y 5 utiliza los dos archivos y comandos de esta sección.