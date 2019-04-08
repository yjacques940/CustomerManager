<?php
session_start();
require('models/ManagerUsers.php');
require('models/Customer.php');
require('services/callApiExtension.php');

$default_locale = 'fr';

if (!isset($_SESSION['locale'])) {
    $_SESSION['locale'] = $default_locale;
}

if (isset($_GET['setLocale'])) {
    $_SESSION['locale'] = $_GET['setLocale'];
}

function permissionDenied() {
    require('views/error.php');
}

function userHasPermission(String $permission): bool
{
    return CallAPI('GET', 'Users/HasPermission', array(
        "idUser" => isset($_SESSION['userid']) ? $_SESSION['userid'] : "0",
        "permission" => $permission
        ))['response'];
}

function localize($phrase)
{
    global $default_locale;
    static $translations = null;
    if (is_null($translations)) {
        $translations = getLocaleFile($_SESSION['locale']);
    }
    if ($translations[$phrase]) {
        return $translations[$phrase];
    } else {
        static $default_translations = null;
        if (is_null($default_translations)) {
            $default_translations = getLocaleFile($default_locale);
        }
        if ($default_translations[$phrase]) {
            return $default_translations[$phrase];
        } else {
            //Raise Error word not defined
            return $phrase;
        }
    }
}

function getLocaleFile($locale)
{
    global $default_locale;
    $lang_file = 'lang/' . $locale . '.json';
    if (!file_exists($lang_file)) {
        //Raise error locale not found
        $lang_file = 'lang/' . $default_locale . '.json';
    }
    $lang_file_content = file_get_contents($lang_file);
    return json_decode($lang_file_content, true);
}


function Login(){
    if(isset($_POST['email'])){
        unset($_SESSION['email']);
        $userRegistered = new ManagerUsers;
        $userIdentification = [
            "email" => htmlentities($_POST['email']),
            "password" => htmlentities($_POST['password'])
        ];
        $userAPI = CallAPI('GET', 'Users/Login', $userIdentification);
        if($userAPI['statusCode'] == 200)
        {
            $_SESSION['username'] = $userAPI['response']->fullName;
            $_SESSION['userid'] = $userAPI['response']->id;
            About();
        }
        else
        {
            require('views/login.php');
        }
    }
    else
    {
        require('views/login.php');
    }
}

function Home(){
    unset($_SESSION['email']);
    require('views/home.php');
}

function Inscription(){
    if(isset($_SESSION['email'])){
        $provinces = new ManagerUsers;
        $result = $provinces->GetProvinces();
        $phoneType = $provinces->GetPhoneType();
        $phoneType2 = $provinces->GetPhoneType();
        $phoneType3 = $provinces->GetPhoneType();
        require('views/personalinformation.php');
    }
    else{
        require('views/inscription.php');
    }
}

function About(){
    unset($_SESSION['email']);
    require('views/about.php');
}

function PersonalInformation(){
    if(!isset($_SESSION['userid'])){
        AddOrUpdateUser();
        unset($_SESSION['email']);
        Login();
    }else{
        if(!empty($_POST)){
            AddOrUpdateUser();
            About();
        }else{
            $provinces = new ManagerUsers;
            $result = $provinces->GetProvinces();
            $phoneType = $provinces->GetPhoneType();
            $phoneType2 = $provinces->GetPhoneType();
            $phoneType3 = $provinces->GetPhoneType();
            $personalInformation = CallAPI('GET','PersonalInformation/PersonalInformation/'.json_encode($_SESSION['userid']));
            require('views/personalinformation.php');
        }
    }
}

function AddOrUpdateUser(){
    if(isset($_POST)){
        if($_POST['address'] != '' and $_POST['city'] != ''
        and $_POST['province'] != '' and $_POST['zipcode'] != '' and $_POST['occupation'] != ''
        and $_POST['phone1'] != '' and $_POST['type1'] != ''){
            $phone1 = array(
                'phone'=>htmlentities($_POST['phone1']),
                'extension'=>'',
                'idPhoneType'=>htmlentities($_POST['type1'])
            );
            if(!empty($_POST['extension1'])){
                $phone1['extension'] = htmlentities($_POST['extension1']);
            }
            if(!empty($_POST['phone2'])){
                $phone2 = array(
                    'phone'=>htmlentities($_POST['phone2']),
                    'extension'=>'',
                    'idPhoneType'=>htmlentities($_POST['type2'])
                );
                if(!empty($_POST['extension2'])){
                    $phone2['extension'] = htmlentities($_POST['extension2']);
                }
            }
            if(!empty($_POST['phone3'])){
                $phone3 = array(
                    'phone'=>htmlentities($_POST['phone3']),
                    'extension'=>'',
                    'idPhoneType'=>htmlentities($_POST['type3'])
                );
                if(!empty($_POST['extension3'])){
                    $phone3['extension'] = htmlentities($_POST['extension3']);
                }
            }
            $physicalAddress = array(
                'physicalAddress'=>htmlentities($_POST['address']),
                'cityName'=>htmlentities($_POST['city']),
                'zipCode'=>htmlentities($_POST['zipcode']),
                'idState'=>htmlentities($_POST['province'])
            );
            $user = array(
                'email'=>(isset($_SESSION['email']))?$_SESSION['email']:'',
                'password'=>(isset($_SESSION['password']))?$_SESSION['password']:''
            );
            $customer = array(
                'sex'=>(isset($_SESSION['gender']))? $_SESSION['gender']:'',
                'firstName'=>(isset($_SESSION['firstName']))? $_SESSION['firstName']:'',
                'lastName'=>(isset($_SESSION['lastName']))? $_SESSION['lastName']:'',
                'birthDate'=>(isset($_SESSION['dateofbirth']))? $_SESSION['dateofbirth']:'',
                'occupation'=>htmlentities($_POST['occupation'])
            );
            $phones = array($phone1);
            if (isset($phone2))
                array_push($phones, $phone2);
            if (isset($phone3))
                array_push($phones, $phone3);

            $registeringInformation = array(
                'physicalAddress'=>$physicalAddress,
                'customer'=>$customer,
                'user'=>$user,
                'phoneNumbers'=>$phones
            ); 
            if(!isset($_SESSION['userid'])){
                $result = CallAPI('POST','Registration/Register/%23definition', json_encode($registeringInformation));
                var_dump($result);
                $_SESSION['registered'] = 'success';
                unset($_SESSION['email']);
                unset($_SESSION['password']);
                unset($_SESSION['firstname']);
                unset($_SESSION['lastname']);
                unset($_SESSION['gender']);
                unset($_SESSION['dateofbirth']);
            }
        }
    }
}

function CheckEmailInUse(){
    $user = new ManagerUsers;
    $emailinUse = $user->CheckEmailInUse(htmlentities($_POST['email']));
    if($emailinUse->fetch())
    {
        echo 'taken';
    }
    else
    {
        if($_POST['email'] != $_POST['email2']){
            echo 'emailerror';
        }else if($_POST['password'] != $_POST['password2']){
            echo 'passworderror';
        }else if($_POST['email'] != '' and $_POST['password'] != ''
                and $_POST['firstname'] != '' and $_POST['lastname'] != ''
                and $_POST['gender']!=''){
            $_SESSION['email'] = htmlentities($_POST['email']);
            $_SESSION['password'] = htmlentities($_POST['password']);
            $_SESSION['firstname'] = htmlentities($_POST['firstname']);
            $_SESSION['lastname'] = htmlentities($_POST['lastname']);
            $_SESSION['gender'] = htmlentities($_POST['gender']);
            $_SESSION['dateofbirth'] = htmlentities($_POST['dateofbirth']);
            echo 'availlable';
        }
        else{
            echo 'emptyfield';
        }
    }
}

function UpdatePassword(){
    if(!empty($_POST)){
        if(isset($_POST['oldpassword']) and isset($_POST['newpassword']) and isset($_POST['confirmedpassword'])){
            if(CheckPasswords()){
                $updatePassword = new ManagerUsers;
                $updatePassword->UpdatePassword(htmlentities($_POST['newpassword']),$_SESSION['userid']);
                About();
            }else{
                require('views/UpdatePassword.php');
            }
        }
    }else{
        require('views/UpdatePassword.php');
    }
}

function UpdateEmail(){
    if(!empty($_POST)){
        if(isset($_POST['newemail']) and isset($_POST['newemailconfirmed']) and isset($_POST['password'])){
            if($_POST['newemail'] == $_POST['newemailconfirmed']){
                $userIdentification = [
                    "userid" => htmlentities($_SESSION['userid']),
                    "password" => htmlentities($_POST['password'])
                ];
                $user = CallAPI('GET', 'Users/CheckPassword',$userIdentification);
                if($user['statusCode'] == 200){
                    $newEmail = [
                        "id" => htmlentities($_SESSION['userid']),
                        "email" => htmlentities($_POST['newemail'])
                    ];
                    $emailUpdate = CallAPI('POST', 'Users/UpdateUserEmail',json_encode($newEmail));
                    About();
                }else{
                    $_SESSION['emailerror'] = 1;
                    require('views/updateEmail.php');
                }
            }else{
                $_SESSION['emaildontmatch'] = 1;
                require('views/updateEmail.php');
            }
        }
    }else{
        require('views/updateEmail.php');
    }
}

function CheckPasswords(){
    $currentPassword = new ManagerUsers;
    $oldpassword = $currentPassword->GetPassword($_SESSION['userid']);
    if($oldpassword != htmlentities($_POST['oldpassword'])){
        return false;
    }else if(htmlentities($_POST['confirmedpassword']) != htmlentities($_POST['newpassword'])){
        return false;
    }else if(htmlentities($_POST['oldpassword']) == '' or htmlentities($_POST['confirmedpassword']) ==''
            or htmlentities($_POST['newpassword']) == ''){
        return false;
    }else if(htmlentities($_POST['oldpassword']) == htmlentities($_POST['newpassword'])){
        return false;
    }else{
        return true;
    }
}

function AskForAppointment()
{
    require('views/ask_for_appointment.php');
}

function SendAskForAppointment()
{
    if(isset($_POST['askForAppointmentDate']) && isset($_POST['appointmentTimeOfDay'])
    && isset($_POST['TypeOfTreatment']))
    {
        $data = array(
            'date' => htmlentities($_POST['askForAppointmentDate']),
            'timeOfDay' => htmlentities($_POST['appointmentTimeOfDay']),
            'typeOfTreatment' => htmlentities($_POST['TypeOfTreatment']),
            'moreInformation' => isset($_POST['moreInformation']) ?
                htmlentities($_POST['moreInformation']) : "",
            'email' => isset($_POST['AskForAppointmentEmail']) ?
                htmlentities($_POST['AskForAppointmentEmail']) : "",
            'userId' => isset($_SESSION['userid']) ? htmlentities($_SESSION['userid']) : "",
            'phoneNumber' => isset($_POST['AskForAppointmentPhoneNumber']) ?
                htmlentities($_POST['AskForAppointmentPhoneNumber']):"",
            'userName' => isset($_POST['AskForAppointmentUserName']) ?
                htmlentities($_POST['AskForAppointmentUserName']) : ""
        );
        $result = CallAPI('POST','Appointments/AskForAppointment',json_encode($data));
        if($result['statusCode'] == 200)
        {
            require('views/confirmation_message.php');
        }
    }
}

function NewAppointments(){
    if (userHasPermission('appointments_read')) {
        $result = CallAPI('GET','Appointments/NewAppointments');
        $newAppointments = $result['response'];
        if($newAppointments)
        {
            require('views/new_appointments.php');
        }
        else
        {
            require('views/appointments.php');
        }
    } else permissionDenied();
}

function Appointments(){
  require('views/appointments.php');
}

function ChangeAppointmentIsNewStatus() {
    if(isset($_POST['newAppointmentIds'])) {
        if (userHasPermission('appointments-write')) {
            CallAPI('POST', 'Appointments/ChangeIsNewStatus',json_encode($_POST['newAppointmentIds']));
            echo 'success';
        } else {
            echo 'Permission Denied';
        }
    } else {
        echo 'No data received';
    }
}

function MakeAppointment(){
    if (isset($_POST)){
        if (userHasPermission('appointments-write')) {
            $appointment = array(
                'AppointmentDateTime' => htmlentities($_POST['appointmentDate'].' '.$_POST['appointmentTime']),
                'DurationTime' => htmlentities($_POST['appointmentDuration']),
                'IdCustomer' => htmlentities($_POST['idCustomer'])
            );
            $result = CallAPI('POST', 'Appointments/CheckAppointmentIsAvailable/%23definition', json_encode($appointment));
            if (!$result->title){
                echo  'success';
            } else {
                echo $result->title;
            }
        } else {
            echo 'Permission Denied';
        }
    } else {
        echo 'No data received';
    }
}

function AppointmentCreator()
{
    require('views/appointment_creator.php');
}
function Customers()
{
    require('views/customers.php');
}
