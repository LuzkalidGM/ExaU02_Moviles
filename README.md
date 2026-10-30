# GameOn Network

Aplicación móvil orientada a deportistas amateur que busca facilitar la búsqueda de instalaciones deportivas, consulta de disponibilidad, coordinación de actividades y gestión de reservas desde un solo lugar.

Proyecto desarrollado para el curso **SI-988 · Soluciones Móviles II** de la Escuela Profesional de Ingeniería de Sistemas de la Universidad Privada de Tacna.

---

## Información del proyecto

| Campo | Detalle |
|---|---|
| Proyecto | GameOn Network |
| Equipo | GameOn Team |
| Curso | SI-988 · Soluciones Móviles II |
| Universidad | Universidad Privada de Tacna |
| Facultad | Facultad de Ingeniería |
| Escuela | Ingeniería de Sistemas |
| Modalidad | Aplicación móvil |
| Estado | En desarrollo |

---

## Problema

Actualmente, los deportistas amateur pueden encontrar dificultades para localizar instalaciones deportivas, conocer su disponibilidad, comparar alternativas y coordinar actividades.

La información suele encontrarse dispersa entre redes sociales, llamadas telefónicas, grupos de mensajería, recomendaciones y consultas directas a los establecimientos.

Esto puede generar pérdida de tiempo, dificultad para coordinar partidos y poca visibilidad sobre las instalaciones deportivas disponibles.

---

## Propuesta de solución

**GameOn Network** busca centralizar la información relacionada con actividades e instalaciones deportivas mediante una aplicación móvil.

La aplicación permitirá progresivamente:

- Visualizar instalaciones deportivas cercanas.
- Buscar espacios según el deporte.
- Consultar información de las instalaciones.
- Revisar horarios y disponibilidad.
- Gestionar reservas.
- Consultar las reservas realizadas.
- Recibir notificaciones y recordatorios.
- Facilitar la coordinación entre deportistas.

Como funcionalidad futura se contempla permitir la creación de partidos abiertos para encontrar otros jugadores interesados en participar.

---

## ¿Por qué una aplicación móvil?

GameOn Network requiere capacidades propias de los dispositivos móviles que permiten mejorar la experiencia del usuario.

Entre ellas se consideran:

- Geolocalización.
- Visualización de instalaciones cercanas mediante mapas.
- Notificaciones.
- Acceso desde cualquier lugar.
- Uso durante el desplazamiento del usuario.
- Posible integración futura con cámara y otras capacidades del dispositivo.

Estas características permiten justificar el desarrollo de una aplicación móvil frente a una solución exclusivamente web.

---

## Público objetivo

El público objetivo principal está compuesto por:

**Deportistas amateur de Tacna** que practican fútbol, vóley, básquet, pádel u otras disciplinas y requieren encontrar instalaciones o coordinar actividades deportivas.

También se considera como usuario del sistema al:

**Administrador de una instalación deportiva**, encargado de registrar y gestionar información relacionada con sus espacios deportivos.

---

## MVP

Para mantener un alcance viable durante el curso, el producto mínimo viable contempla inicialmente:

1. Registro e inicio de sesión.
2. Perfil básico del usuario.
3. Visualización de instalaciones deportivas.
4. Geolocalización y mapa.
5. Búsqueda y filtros por deporte.
6. Información de cada instalación.
7. Consulta de disponibilidad.
8. Reserva de instalaciones.
9. Consulta de reservas realizadas.
10. Notificaciones y recordatorios.

Las funcionalidades adicionales serán evaluadas de acuerdo con el avance de los sprints.

---

## Equipo Scrum

| Integrante | Rol Scrum | Área principal |
|---|---|---|
| Sebastián Fuentes | Product Owner | Desarrollo móvil y diseño UI/UX |
| Gabriela Gutierrez | Scrum Master | Backend y base de datos |
| Mayra Chire | Developer | Pruebas e integración |

---

## Organización del repositorio

```text
pro_moviles_ii_capicodex/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── app/
│
├── docs/
│   ├── arquitectura/
│   ├── decisiones/
│   ├── entorno/
│   ├── equipo/
│   │   ├── EQUIPO.md
│   │   └── ACUERDOS.md
│   │
│   ├── evidencias/
│   │   └── S01/
│   │
│   ├── producto/
│   │   ├── LEAN_CANVAS.md
│   │   ├── VALIDACION.md
│   │   └── VISION.md
│   │
│   └── sprints/
│
├── src/
├── test/
├── .gitignore
├── CONTRIBUTING.md
└── README.md
## Tipo de examen: 3

### Ítem 1: consentimiento (implementado)
- La primera apertura muestra Privacidad antes del inicio habitual, conservando el flujo de autenticación.
- Analítica de uso y Notificaciones promocionales comienzan apagadas.
- Aceptar guarda los interruptores seleccionados; Rechazar guarda ambos apagados. Los dos botones tienen el mismo estilo y tamaño.
- La decisión se guarda localmente junto con la política 1.0 y la fecha UTC en ISO 8601.
- Perfil > Privacidad permite revisar y cambiar la decisión con o sin sesión.
- El permiso de notificaciones del sistema sigue siendo independiente del consentimiento promocional.
- El repositorio se inyecta en el ViewModel; las pruebas usan almacenamiento falso.

Archivos móviles creados:
- `gameon_mobile/lib/features/privacidad/models/consentimiento.dart`
- `gameon_mobile/lib/features/privacidad/repositories/consentimiento_repository.dart`
- `gameon_mobile/lib/features/privacidad/viewmodels/consentimiento_viewmodel.dart`
- `gameon_mobile/lib/features/privacidad/views/privacidad_view.dart`
- `gameon_mobile/test/features/privacidad/consentimiento_test.dart`

Archivos móviles modificados:
- `gameon_mobile/lib/main.dart`
- `gameon_mobile/lib/features/perfil/views/perfil_view/authenticated/perfil_authenticated_view.dart`
- `gameon_mobile/lib/features/perfil/views/perfil_view/unauthenticated/perfil_unauthenticated_view.dart`

Validación: `flutter test` (47 pruebas correctas) y `flutter analyze lib/features/privacidad lib/main.dart` (sin problemas).

Ítems 4 y 5 completados: consulta los comandos finales de pruebas al final de este documento.
Consultar `EVIDENCIAS.md` para las capturas y la explicación técnica.
### Ítem 2: datos mínimos al guardar el perfil (implementado)
- DTO GuardarPerfilRequest separado de UsuarioDeportista, con conversión fromUsuario y lista explícita de campos editables.
- EditPerfilViewModel utiliza el DTO en la petición real de actualización; excluye metadatos, deportes y token FCM. auth_id se toma de la sesión únicamente para crear el perfil.
- Esta petición no lleva coordenadas.
- Archivos creados: `gameon_mobile/lib/features/perfil/models/guardar_perfil_request.dart` y `gameon_mobile/test/features/perfil/guardar_perfil_request_test.dart`.
- Archivos modificados: `gameon_mobile/lib/features/perfil/viewmodels/edit_perfil_viewmodel.dart` y `gameon_mobile/lib/features/perfil/views/perfil_view/authenticated/edit_perfil/edit_perfil_view.dart`.
- Validación: 49 pruebas correctas. El esquema local no incluye usuarios_deportistas; se mantuvo el contrato del flujo existente y no se hicieron escrituras remotas de prueba.
- EVIDENCIAS.md contiene tabla campo/decisión/motivo e instrucciones de captura del PATCH con Flutter DevTools.
### Ítem 3: logs y analítica (implementado)
- PiiMasker oculta correo, celular, DNI y URLs; AppLogger enmascara mensaje, nombre, errores y trazas antes de escribir.
- Se migraron todos los logs propios de 15 archivos a AppLogger y se quitaron los console.log del script de PayPal.
- AnalyticsService se inyecta desde main; ConsentAwareAnalyticsService consulta el consentimiento actual antes de cada evento.
- Guardar perfil produce una línea enmascarada de datos ficticios y el evento perfil_guardado condicionado al consentimiento.
- Creados: lib/core/logging/pii_masker.dart, lib/core/logging/app_logger.dart, lib/core/services/analytics_service.dart y test/core/privacy_logging_test.dart (rutas relativas a gameon_mobile).
- Modificados: lib/main.dart; core/services/notification_service.dart y notification_navigation_service.dart; features/chat/viewmodels/chat_list_viewmodel.dart, conversation_viewmodel.dart y find_players_viewmodel.dart; features/home/viewmodels/home_viewmodel.dart y views/mapa_instituciones_view.dart; features/perfil/services/email_service.dart, viewmodels/perfil_viewmodel.dart, viewmodels/edit_perfil_viewmodel.dart y views/perfil_view/authenticated/edit_perfil/edit_perfil_view.dart; features/reservas/viewmodels/reserva_resumen_viewmodel.dart, reserva_calendario_viewmodel.dart, reservas_list_viewmodel.dart y views/paypal_webview.dart. Todos bajo gameon_mobile/lib.
- Verificación: 54 pruebas correctas y cero logs directos fuera de AppLogger en lib. EVIDENCIAS.md incluye búsqueda compatible con PowerShell, filtros y capturas.
### Ítems 4 y 5: pruebas del examen completadas

Todos los comandos se ejecutan desde `gameon_mobile`.

| Ítem | Archivo creado | Resultado |
|---|---|---|
| 4 | test/examen_tipo3/item4_consentimiento_test.dart | 3/3 PASS |
| 5 | test/examen_tipo3/item5_enmascarado_envio_test.dart | 2/2 PASS |

El ítem 4 usa almacenamiento y analítica falsos en memoria. Cubre opciones apagadas, aceptación selectiva con versión 1.0 y bloqueo de eventos después de retirar consentimiento. El ítem 5 usa el enmascarador y DTO reales: verifica la ausencia del correo/celular/DNI original y la lista exacta del cuerpo serializado sin metadatos. El perfil no contiene coordenadas, por lo que no aplica redondearlas.

Se reubicaron casos de `test/core/privacy_logging_test.dart`, `test/features/privacidad/consentimiento_test.dart` y `test/features/perfil/guardar_perfil_request_test.dart` para evitar duplicación. Los demás casos de esos archivos se conservan. El escenario sin consentimiento también verifica que no se entregue analítica; por eso dos pruebas anteriores se consolidaron en una.

```powershell
flutter test test/examen_tipo3/item4_consentimiento_test.dart --reporter expanded
flutter test test/examen_tipo3/item5_enmascarado_envio_test.dart --reporter expanded
flutter test --reporter expanded
```

Resultado final: 53 pruebas totales correctas (los conteos de 47, 49 y 54 anteriores corresponden a etapas previas). Análisis de los archivos de pruebas reorganizados: sin problemas. No se requiere emulador, cuenta ni red para estos escenarios; se usan las dependencias ya instaladas.