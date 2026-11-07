<?php
session_start();
$_SESSION['visits'] = ($_SESSION['visits'] ?? 0) + 1;

$serverSoftware = $_SERVER['SERVER_SOFTWARE'] ?? 'unknown';
$hostname       = gethostname();
$phpVersion     = phpversion();
$now            = date('Y-m-d H:i:s');
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>PHP on EC2 - Nginx + Apache2</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="card">
    <h1>🚀 PHP App running on AWS EC2</h1>
    <p>Served through <strong>Nginx</strong> (reverse proxy) → <strong>Apache2 + PHP</strong> (backend).</p>

    <table>
        <tr><th>PHP Version</th><td><?php echo htmlspecialchars($phpVersion); ?></td></tr>
        <tr><th>Server Software (backend)</th><td><?php echo htmlspecialchars($serverSoftware); ?></td></tr>
        <tr><th>Hostname</th><td><?php echo htmlspecialchars($hostname); ?></td></tr>
        <tr><th>Server Time</th><td><?php echo htmlspecialchars($now); ?></td></tr>
        <tr><th>Session Visits</th><td><?php echo (int)$_SESSION['visits']; ?></td></tr>
    </table>

    <p><a href="about.php">About this deployment →</a></p>
</div>
</body>
</html>
