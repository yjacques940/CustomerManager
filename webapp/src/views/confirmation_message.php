<?php
$titre = localize('Email-Send-Admins');
ob_start(); ?>
<section class="contact py-lg-4 py-md-3 py-sm-3 py-3">
    <div class="container py-lg-5 py-md-4 py-sm-4 py-3">
        <h3 class="text-center mb-md-4 mb-sm-3 mb-3 mb-2"><?php echo localize($titre) ?></h3>

    </div></section>
<?php $contenu = ob_get_clean();
$onHomePage = false;
require 'gabarit.php'; ?>
