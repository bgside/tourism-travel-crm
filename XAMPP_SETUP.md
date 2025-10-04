# 🚀 XAMPP Setup Guide for Tourism & Travel CRM

## Complete XAMPP Configuration for Optimal Performance

This guide provides step-by-step instructions to set up XAMPP for the **Tourism & Travel CRM System** with optimized configurations for handling travel bookings, multilingual content, and high-performance operations.

---

## 📋 **System Requirements**

### **Minimum Requirements**
- **RAM:** 4GB (8GB recommended)
- **Storage:** 2GB free space (5GB recommended)
- **PHP:** 8.3 or higher
- **MySQL:** 8.0 or higher
- **Apache:** 2.4 or higher

### **Recommended System**
- **RAM:** 16GB for optimal performance
- **Storage:** 10GB+ for demo data and file uploads
- **SSD:** Recommended for database performance

---

## 🛠️ **XAMPP Installation**

### **Step 1: Download XAMPP**
1. Visit [XAMPP Official Website](https://www.apachefriends.org/download.html)
2. Download **PHP 8.3** version for Windows
3. Run the installer as Administrator

### **Step 2: Installation Configuration**
```
Select Components:
☑️ Apache
☑️ MySQL  
☑️ PHP
☑️ phpMyAdmin
☑️ Webalizer
☐ FileZilla FTP Server (optional)
☐ Mercury Mail Server (optional)
☐ Tomcat (not needed)
```

### **Step 3: Installation Path**
- **Recommended:** `C:\\xampp\\` (default)
- **Alternative:** `D:\\xampp\\` (if C: drive is limited)

---

## ⚙️ **PHP Configuration Optimization**

### **Edit php.ini File**
Location: `C:\xampp\php\php.ini`

```ini
; ===============================================
; Tourism CRM Optimized PHP Configuration
; ===============================================

; Basic Settings
max_execution_time = 300
max_input_time = 300
memory_limit = 512M

; File Upload Settings (for travel documents/images)
file_uploads = On
upload_max_filesize = 50M
max_file_uploads = 100
post_max_size = 50M

; Session Settings
session.gc_maxlifetime = 7200
session.cookie_lifetime = 7200

; Date & Timezone (adjust for your location)
date.timezone = "UTC"

; Error Reporting (Development)
error_reporting = E_ALL
display_errors = On
display_startup_errors = On
log_errors = On
error_log = C:\\xampp\\php\\logs\\php_error.log

; OPcache Settings (Performance)
opcache.enable = 1
opcache.enable_cli = 1
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 12
opcache.max_accelerated_files = 10000
opcache.validate_timestamps = 1
opcache.revalidate_freq = 60
opcache.save_comments = 1

; Extensions for Tourism CRM
extension=curl
extension=fileinfo
extension=gd
extension=intl
extension=mbstring
extension=mysqli
extension=openssl
extension=pdo_mysql
extension=zip
extension=xml
extension=json
extension=redis
extension=imagick

; Multibyte String Settings
mbstring.language = UTF-8
mbstring.internal_encoding = UTF-8
mbstring.http_output = UTF-8
mbstring.encoding_translation = On
mbstring.detect_order = UTF-8,SJIS,EUC-JP,JIS,ASCII
```

---

## 🗄️ **MySQL Configuration Optimization**

### **Edit my.ini File**
Location: `C:\xampp\mysql\bin\my.ini`

```ini
# ===============================================
# Tourism CRM Optimized MySQL Configuration
# ===============================================

[mysql]
default-character-set = utf8mb4

[mysqld]
# Basic Settings
port = 3306
socket = /tmp/mysql.sock
key_buffer_size = 256M
max_allowed_packet = 128M
table_open_cache = 2000
sort_buffer_size = 4M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
myisam_sort_buffer_size = 64M
thread_cache_size = 8
query_cache_size = 128M
query_cache_limit = 2M
query_cache_type = 1

# Character Set (for Arabic/English support)
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init-connect = 'SET NAMES utf8mb4'

# Connection Settings
max_connections = 200
max_connect_errors = 100
concurrent_insert = 2
connect_timeout = 60
wait_timeout = 28800
interactive_timeout = 28800

# InnoDB Settings (for transactions & foreign keys)
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
innodb_log_buffer_size = 16M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50
innodb_file_per_table = 1

# Binary Logging (for backup/replication)
log-bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7

# Slow Query Log (for optimization)
slow_query_log = 1
slow_query_log_file = C:\\xampp\\mysql\\data\\slow.log
long_query_time = 2

# General Query Log (development only)
general_log = 1
general_log_file = C:\\xampp\\mysql\\data\\general.log

[mysqldump]
quick
quote-names
max_allowed_packet = 128M

[isamchk]
key_buffer_size = 128M
sort_buffer_size = 128M
read_buffer = 2M
write_buffer = 2M

[myisamchk]
key_buffer_size = 128M
sort_buffer_size = 128M
read_buffer = 2M
write_buffer = 2M
```

---

## 🌐 **Apache Configuration**

### **Edit httpd.conf File**
Location: `C:\xampp\apache\conf\httpd.conf`

```apache
# ===============================================
# Tourism CRM Optimized Apache Configuration
# ===============================================

# Server Performance
Timeout 300
KeepAlive On
KeepAliveTimeout 5
MaxKeepAliveRequests 100

# Memory and Process Settings
ServerLimit 16
MaxRequestWorkers 400
ThreadsPerChild 25

# Enable Modules
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule headers_module modules/mod_headers.so

# Document Root
DocumentRoot "C:/xampp/htdocs"

# Directory Settings
<Directory "C:/xampp/htdocs">
    Options Indexes FollowSymLinks Includes ExecCGI
    AllowOverride All
    Require all granted
</Directory>

# File Upload Limits
LimitRequestBody 52428800

# Compression (for faster loading)
LoadModule deflate_module modules/mod_deflate.so
<Location />
    SetOutputFilter DEFLATE
    SetEnvIfNoCase Request_URI \
        \.(?:gif|jpe?g|png|ico)$ no-gzip dont-vary
    SetEnvIfNoCase Request_URI \
        \.(?:exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary
</Location>

# Security Headers
Header always set X-Frame-Options SAMEORIGIN
Header always set X-Content-Type-Options nosniff
Header always set X-XSS-Protection "1; mode=block"
```

---

## 📁 **Project Setup in XAMPP**

### **Method 1: htdocs Directory (Recommended)**
1. Extract project to: `C:\xampp\htdocs\tourism-crm\`
2. Access via: `http://localhost/tourism-crm`

### **Method 2: Virtual Host (Advanced)**
1. Edit `C:\xampp\apache\conf\extra\httpd-vhosts.conf`:

```apache
<VirtualHost *:80>
    DocumentRoot "C:/xampp/htdocs/tourism-crm/public"
    ServerName tourism-crm.local
    ServerAlias www.tourism-crm.local
    <Directory "C:/xampp/htdocs/tourism-crm/public">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

2. Edit `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1    tourism-crm.local
```

3. Access via: `http://tourism-crm.local`

---

## 🔧 **Redis Setup (Optional but Recommended)**

### **Install Redis for Windows**
1. Download from: [Redis Windows Release](https://github.com/tporadowski/redis/releases)
2. Extract to `C:\redis\`
3. Run `redis-server.exe`

### **Configure Laravel for Redis**
In `.env` file:
```env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

---

## 🗃️ **Database Setup**

### **Create Tourism CRM Database**
1. Open phpMyAdmin: `http://localhost/phpmyadmin`
2. Create new database: `tourism_crm`
3. Collation: `utf8mb4_unicode_ci`

### **Import Demo Data (Optional)**
```sql
-- Sample SQL for quick testing
CREATE DATABASE tourism_crm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tourism_crm;

-- Demo user (password: admin123)
INSERT INTO users (name, email, password, role, created_at, updated_at) 
VALUES ('Admin User', 'admin@tourism-crm.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', NOW(), NOW());
```

---

## 🚀 **Performance Optimization**

### **Windows System Optimization**
1. **Disable Windows Defender** real-time protection for XAMPP folders
2. **Add XAMPP to exclusions:**
   - `C:\xampp\`
   - `C:\xampp\htdocs\tourism-crm\`
   - `C:\xampp\mysql\data\`

### **XAMPP Service Configuration**
1. **Run as Administrator** for better performance
2. **Set services to start automatically:**
   - Apache
   - MySQL

### **Development Environment Variables**
Add to `C:\xampp\htdocs\tourism-crm\.env`:
```env
APP_NAME="Tourism & Travel CRM"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost/tourism-crm

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=tourism_crm
DB_USERNAME=root
DB_PASSWORD=

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_ENCRYPTION=tls
```

---

## 🔒 **Security Configuration**

### **Production Security (when deploying)**
```ini
; Production php.ini settings
display_errors = Off
display_startup_errors = Off
error_reporting = E_ERROR | E_WARNING | E_PARSE
expose_php = Off
```

### **MySQL Security**
1. Set root password in phpMyAdmin
2. Remove test databases
3. Create dedicated CRM user:

```sql
CREATE USER 'tourism_crm'@'localhost' IDENTIFIED BY 'secure_password_here';
GRANT ALL PRIVILEGES ON tourism_crm.* TO 'tourism_crm'@'localhost';
FLUSH PRIVILEGES;
```

---

## 📊 **Monitoring & Maintenance**

### **Log Files Locations**
- **PHP Errors:** `C:\xampp\php\logs\php_error.log`
- **Apache Access:** `C:\xampp\apache\logs\access.log`
- **Apache Errors:** `C:\xampp\apache\logs\error.log`
- **MySQL Errors:** `C:\xampp\mysql\data\mysql_error.log`

### **Regular Maintenance**
1. **Clear log files** regularly to save space
2. **Backup database** before major changes
3. **Monitor PHP memory usage** during development
4. **Update XAMPP** for security patches

### **Performance Monitoring**
Access built-in tools:
- **phpMyAdmin:** `http://localhost/phpmyadmin`
- **Server Status:** `http://localhost/dashboard`
- **PHP Info:** Create `info.php` with `<?php phpinfo(); ?>`

---

## 🐛 **Troubleshooting Common Issues**

### **Port Conflicts**
If Apache won't start (Port 80 busy):
1. Open XAMPP Control Panel
2. Click "Config" next to Apache
3. Edit `httpd.conf`: Change `Listen 80` to `Listen 8080`
4. Access via: `http://localhost:8080/tourism-crm`

### **MySQL Won't Start**
1. Check if MySQL service is running
2. Check port 3306 availability
3. Review `mysql_error.log` for issues

### **Memory Issues**
Increase PHP memory in `php.ini`:
```ini
memory_limit = 1G
```

### **Upload Issues**
Check upload settings in `php.ini`:
```ini
file_uploads = On
upload_max_filesize = 100M
post_max_size = 100M
max_file_uploads = 50
```

---

## ✅ **Verification Checklist**

After setup, verify these work:

### **✅ Basic Functionality**
- [ ] XAMPP Control Panel opens
- [ ] Apache starts successfully
- [ ] MySQL starts successfully  
- [ ] phpMyAdmin accessible
- [ ] PHP info page displays

### **✅ CRM Specific**
- [ ] Laravel application loads
- [ ] Database connection works
- [ ] File uploads function (travel documents)
- [ ] Arabic text displays correctly
- [ ] Email configuration works
- [ ] Redis caching (if enabled)

### **✅ Performance**
- [ ] Page load times < 2 seconds
- [ ] Large image uploads work
- [ ] Multiple concurrent users supported
- [ ] Background jobs process

---

## 🎯 **Quick Start Commands**

Once XAMPP is configured, use these commands:

```bash
# Navigate to project directory
cd C:\xampp\htdocs\tourism-crm

# Install dependencies
composer install
npm install

# Setup environment
copy .env.example .env
php artisan key:generate
php artisan storage:link

# Database setup
php artisan migrate
php artisan db:seed --class=TourismDemoSeeder

# Build assets
npm run build

# Start Laravel (if not using Apache)
php artisan serve --host=0.0.0.0 --port=8000
```

---

## 🚀 **Production Deployment Tips**

When moving to production:

1. **Change environment to production** in `.env`
2. **Set strong database passwords**
3. **Configure proper SSL certificates**
4. **Enable security headers**
5. **Set up automated backups**
6. **Configure email properly**
7. **Set up monitoring and logging**

---

## 📞 **Support & Additional Resources**

### **Official Documentation**
- [Laravel 11 Documentation](https://laravel.com/docs/11.x)
- [XAMPP Documentation](https://www.apachefriends.org/docs/)
- [Vue.js 3 Guide](https://vuejs.org/guide/)

### **Tourism CRM Specific**
- **GitHub Issues:** Report problems or request features
- **Wiki Documentation:** Detailed feature guides
- **Demo Environment:** Test all features before customization

---

*This XAMPP setup is optimized specifically for the Tourism & Travel CRM System. Following these configurations will ensure optimal performance for travel bookings, multilingual content, and high-traffic operations.* 🌍✈️

---

**Last Updated:** October 2024  
**Compatible with:** XAMPP 8.3.x, Tourism CRM v1.0+