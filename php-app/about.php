<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>About - Architecture</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="card">
    <h1>Architecture</h1>
    <ol>
        <li><strong>Client</strong> hits the EC2 public IP on port 80.</li>
        <li><strong>Nginx</strong> listens on port 80. It serves static assets (CSS/JS/images) directly
            and reverse-proxies every request (including .php) to Apache on <code>127.0.0.1:8080</code>.</li>
        <li><strong>Apache2 + mod_php</strong> listens only on <code>127.0.0.1:8080</code> (not exposed
            publicly) and executes the PHP application.</li>
    </ol>
    <p>This setup is common when you want Nginx's speed for static content and load balancing,
       while keeping Apache's <code>.htaccess</code> support for the app itself.</p>
    <p><a href="index.php">← Back home</a></p>
</div>
</body>
</html>
