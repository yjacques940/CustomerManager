<?php
$titre = localize('Email-Send-Admins');
ob_start();
unset($_SESSION['TempCustomerId']);
?>

<a href="?action=mainMedicalSurvey&idCustomer=<?php echo $_GET['customerId']?>">Consulter le questionnaire : id client = <?php echo $_GET['customerId']?></a>
</br>
<a href="index.php?action=followuplist&customerId=<?php echo $customerId?>">Liste des suivis </a>
<?php $contenu = ob_get_clean();
$onHomePage = false;
require 'gabarit.php'; ?>
