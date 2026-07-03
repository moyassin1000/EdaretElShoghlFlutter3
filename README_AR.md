# تطبيق إدارة الشغل - Flutter

مشروع Flutter كامل لتطبيق Android عربي RTL يعمل بدون إنترنت، ويستخدم SQLite لحفظ السجلات وSharedPreferences لحفظ تسجيل الدخول والإعدادات.

## بيانات الدخول الافتراضية

- اسم المستخدم: `admin`
- كلمة المرور: `admin123`

يمكن تغيير كلمة المرور من شاشة الإعدادات داخل التطبيق.

## أهم المميزات

- Splash Screen احترافية مع Animation وLoading.
- Login Screen مع Remember Me وحفظ حالة الدخول.
- Dashboard بإحصائيات: الإيرادات، المصاريف، صافي الربح، عدد السجلات، آخر سجل.
- إضافة بيانات يومية مع حساب المصاريف والصافي تلقائيًا.
- عرض السجلات من SQLite مع بحث وفلترة وتعديل وحذف وتأكيد قبل الحذف.
- شاشة تفاصيل لكل سجل.
- تقارير يومية وشهرية وسنوية وفترة مخصصة.
- رسم بياني بسيط للإيرادات والمصاريف.
- تصدير PDF، وتصدير CSV يمكن فتحه في Excel، ومشاركة التقرير.
- Settings: تغيير كلمة المرور، الثيم، اسم التطبيق داخل الواجهة، Backup/Restore، مسح البيانات، Logout.
- RTL كامل واللغة عربية.
- يعمل بدون إنترنت.

## هيكل المشروع

```text
lib/
  models/
  database/
  services/
  providers/
  screens/
  widgets/
  themes/
  utils/
tools/
.github/workflows/
```

## قاعدة البيانات

اسم الجدول: `work_records`

الأعمدة:

```sql
id INTEGER PRIMARY KEY AUTOINCREMENT
date TEXT
title TEXT
revenue REAL
fuel REAL
garage REAL
maintenance REAL
other_expenses REAL
total_expenses REAL
net_profit REAL
notes TEXT
created_at TEXT
updated_at TEXT
```

## بناء APK Release بدون Android Studio باستخدام GitHub Actions

هذه أسهل طريقة إذا لم يكن لديك Android Studio.

1. افتح GitHub من المتصفح.
2. أنشئ Repository جديد.
3. ارفع كل ملفات هذا المشروع كما هي.
4. افتح تبويب `Actions`.
5. اختر Workflow باسم `Build Flutter Release APK`.
6. اضغط `Run workflow`.
7. بعد انتهاء البناء، افتح آخر Run.
8. ستجد Artifact باسم:

```text
EdaretElShoghl-Release-APK
```

قم بتحميله، وستجد داخله:

```text
app-release.apk
```

هذا هو ملف APK Release القابل للتثبيت.

## بناء APK محليًا بدون Android Studio

يمكن البناء من سطر الأوامر فقط إذا كان Flutter SDK مثبتًا لديك:

```bash
flutter create --platforms=android --org com.edaretelshoghl .
flutter pub get
python tools/patch_android_release.py
flutter build apk --release
```

بعد البناء ستجد APK هنا:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## تغيير اسم التطبيق

اسم التطبيق داخل واجهة المستخدم يمكن تغييره من شاشة الإعدادات.

لتغيير الاسم الظاهر تحت الأيقونة في Android، عدّل المتغير داخل:

```text
tools/patch_android_release.py
```

ابحث عن:

```python
APP_NAME = "إدارة الشغل"
```

ثم شغّل البناء مرة أخرى.

## تغيير Package ID

من نفس الملف:

```python
PACKAGE_ID = "com.edaretelshoghl.app"
```

## تغيير الألوان والثيم

الملف الأساسي:

```text
lib/themes/app_theme.dart
```

الثيمات الموجودة:

- Premium Mode
- Dark Mode
- Light Mode

## تغيير بيانات الدخول الافتراضية

الملف:

```text
lib/utils/app_constants.dart
```

```dart
static const String defaultUsername = 'admin';
static const String defaultPassword = 'admin123';
```

بعد أول تشغيل يتم حفظ البيانات في SharedPreferences. لتغيير كلمة المرور على جهاز مستخدم فعلي، استخدم شاشة الإعدادات.

## تغيير اللوجو والأيقونة

التطبيق يستخدم حاليًا أيقونة Flutter الافتراضية على Android مع لوجو داخلي برمجي. لتغيير أيقونة Android التجارية:

1. بعد تشغيل `flutter create` سيكون لديك مجلد `android/`.
2. استبدل ملفات الأيقونة داخل:

```text
android/app/src/main/res/mipmap-*/
```

أو استخدم حزمة `flutter_launcher_icons` إذا أردت توليد الأيقونات آليًا.

## ملاحظة عن خطوط Cairo/Tajawal

لم يتم تضمين ملفات خطوط داخل المشروع. إذا أردت خط Cairo أو Tajawal، أضف ملفات الخط المرخصة لديك داخل:

```text
assets/fonts/
```

ثم عرّفها في `pubspec.yaml` وعدّل `fontFamily` داخل `lib/themes/app_theme.dart`.

## ملاحظة عن PDF عربي

حزمة PDF تحتاج Font يدعم العربية لكي تظهر الحروف العربية بشكل مثالي داخل ملف PDF. التطبيق يحتوي على كود تصدير PDF، لكن للحصول على أفضل نتيجة عربية أضف خطًا عربيًا مرخصًا داخل assets ومرره إلى خدمة التصدير.

## اختبارات مقترحة قبل الاستخدام

- تسجيل الدخول: admin / admin123.
- إضافة سجل جديد.
- تعديل سجل.
- حذف سجل.
- البحث باسم البيان.
- فلترة بالتاريخ.
- عرض التقرير الشهري.
- تصدير CSV/PDF ومشاركته.
- إغلاق التطبيق وفتحه للتأكد من بقاء البيانات وحالة الدخول.
- تغيير الثيم وكلمة المرور.
- عمل Backup ثم Restore.
