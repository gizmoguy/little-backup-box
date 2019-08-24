<html lang="en">
    <!-- Author: Dmitri Popov, dmpop@linux.com
         License: GPLv3 https://www.gnu.org/licenses/gpl-3.0.txt -->

    <head>
	<meta charset="utf-8">
	<title>Little Backup Box</title>
	<link rel="shortcut icon" href="favicon.png" />
	<link rel="stylesheet" href="milligram.min.css">
	<link rel="stylesheet" href="//fonts.googleapis.com/css?family=Roboto:300,300italic,700,700italic">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<style>
	 #content {
	     margin: 0px auto;
             text-align: center;
	 }
	 h2 {
	     letter-spacing: 3px;
	 }
	 img {
	     display: block;
	     margin-left: auto;
	     margin-right: auto;
	     margin-top: 1%;
	     margin-bottom: 1%;
	 }
	 button {width: 175px;}
	 button.red { background-color: #f44336; border: none; }
	</style>
    </head>

    <body>
	<?php
	// include i18n class and initialize it
	require_once 'i18n.class.php';
	$i18n = new i18n('lang/{LANGUAGE}.ini', 'cache/', 'en');
	$i18n->init();
	?>
	<div id="content">
	    <a href="/"><img src="logo.svg" height="51px" alt="Little Backup Box"></a>
            <h2>Little Backup Box</h2>
        <p class="left"><?php echo L::sysinfo_lbl; ?></p>
        <p>
           <form method="get" action="sysinfo.php">
                <button class="red"><?php echo L::sysinfo_btn; ?></button>
           </form>
        </p>
        <p class="left"><?php echo L::shutdown_lbl; ?></p>
        <p>
           <form method="post">
                <button class="red" name="shutdown"><?php echo L::shutdown_btn; ?></button>
           </form>
        </p>

	    <?php
	    if (isset($_POST['shutdown']))
	    {
		shell_exec('sudo shutdown -h now > /dev/null 2>&1 & echo $!');
		echo '<script language="javascript">';
		echo 'alert("'.L::shutdown_msg.'")';
		echo '</script>';
	    }
	    ?>
        <p><a href="https://gumroad.com/l/linux-photography"><img src="info.svg" height="35px" alt="Linux Photography book"></a></p>
	</div>
    </body>
</html>
