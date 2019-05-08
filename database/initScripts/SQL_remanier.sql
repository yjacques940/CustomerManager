DROP DATABASE IF EXISTS main_db;
create database if not exists main_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
use main_db;

#------------------------------------------------------------
# Table: tbl_country
#------------------------------------------------------------

CREATE TABLE tbl_country(
        id_country Int  Auto_increment  NOT NULL ,
        name       Varchar (25) NOT NULL UNIQUE ,
        is_active  Bool NOT NULL DEFAULT 1
	,CONSTRAINT tbl_country_PK PRIMARY KEY (id_country)
)ENGINE=InnoDB ;


#------------------------------------------------------------
# Table: tbl_state
#------------------------------------------------------------

CREATE TABLE tbl_state(
        id_state   Int  Auto_increment  NOT NULL ,
        name       Varchar (50) NOT NULL UNIQUE,
        code       Varchar (2) NOT NULL UNIQUE,
        is_active  Bool NOT NULL DEFAULT 1 ,
        id_country Int NOT NULL
	,CONSTRAINT tbl_state_PK PRIMARY KEY (id_state)

	,CONSTRAINT tbl_state_tbl_country_FK FOREIGN KEY (id_country) REFERENCES tbl_country(id_country)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: tbl_address
#------------------------------------------------------------

CREATE TABLE tbl_address(
        id_address Int  Auto_increment  NOT NULL ,
        physical_address    Varchar (150) NOT NULL ,
        city_name  Varchar (75) NOT NULL ,
        zip_code   Varchar (10) NOT NULL ,
        is_active  Bool NOT NULL DEFAULT 1 ,
        id_state   Int NOT NULL
	,CONSTRAINT tbl_address_PK PRIMARY KEY (id_address)

	,CONSTRAINT tbl_address_tbl_state_FK FOREIGN KEY (id_state) REFERENCES tbl_state(id_state)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Table: tbl_phone_type
#------------------------------------------------------------

CREATE TABLE tbl_phone_type(
        id_phone_type Int  Auto_increment  NOT NULL ,
        name          Varchar (15) NOT NULL UNIQUE,
        is_active     Bool NOT NULL DEFAULT 1
	,CONSTRAINT tbl_phone_type_PK PRIMARY KEY (id_phone_type)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Table: tbl_customer
#------------------------------------------------------------

CREATE TABLE tbl_customer(
        id_customer Int  Auto_increment  NOT NULL ,
        sex         Char (1) NOT NULL ,
        first_name  Varchar (50) NOT NULL ,
        last_name   Varchar (50) NOT NULL ,
        birth_date  DateTime NOT NULL ,
        occupation  Varchar (100) NOT NULL ,
        is_active   Bool NOT NULL DEFAULT 1 ,
        id_address  Int NOT NULL
	,CONSTRAINT tbl_customer_PK PRIMARY KEY (id_customer)
	,CONSTRAINT tbl_customer_tbl_address_FK FOREIGN KEY (id_address) REFERENCES tbl_address(id_address)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Table: tbl_phone_number   --- VOIR À RENDRE UNIQUE LE NUMÉRO DE TÉLÉPHONE ET EXTENSION COMBINÉ ---
#------------------------------------------------------------

CREATE TABLE tbl_phone_number(
        id_phone_number Int  Auto_increment  NOT NULL ,
        phone		    Varchar (15) NOT NULL ,
        extension       Varchar (10) ,
        is_active       Bool NOT NULL DEFAULT 1 ,
        id_phone_type   Int NOT NULL,
        id_customer Int NOT NULL
	,CONSTRAINT tbl_phone_number_PK PRIMARY KEY (id_phone_number)
    ,CONSTRAINT tbl_customer_tbl_phone_number_FK FOREIGN KEY (id_customer) REFERENCES tbl_customer(id_customer)
	,CONSTRAINT tbl_phone_number_tbl_phone_type_FK FOREIGN KEY (id_phone_type) REFERENCES tbl_phone_type(id_phone_type)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Table: tbl_user
#------------------------------------------------------------

CREATE TABLE tbl_user(
        id_user     Int  Auto_increment  NOT NULL ,
        email       Varchar (256) NOT NULL UNIQUE,
        password    Varchar (256) NOT NULL ,
        role        Int (8) NOT NULL DEFAULT 0,
        created_on  Datetime NOT NULL DEFAULT current_timestamp ,
        last_login  Datetime NOT NULL DEFAULT current_timestamp ,
        is_active   Bool NOT NULL DEFAULT 1 ,
        id_customer Int NOT NULL
	,CONSTRAINT tbl_user_PK PRIMARY KEY (id_user)

	,CONSTRAINT tbl_user_tbl_customer_FK FOREIGN KEY (id_customer) REFERENCES tbl_customer(id_customer)
	,CONSTRAINT tbl_user_tbl_customer_AK UNIQUE (id_customer)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: tbl_permissions
#------------------------------------------------------------

CREATE TABLE tbl_permission(
        id_permissions Int  Auto_increment  NOT NULL ,
        is_active      Bool NOT NULL DEFAULT 1 ,
        bit            Int (8) NOT NULL UNIQUE ,
        name           Varchar (64) NOT NULL UNIQUE
	,CONSTRAINT tbl_permissions_PK PRIMARY KEY (id_permissions)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: tbl_follow_up
#------------------------------------------------------------

CREATE TABLE tbl_follow_up(
        id_follow_up Int  Auto_increment  NOT NULL ,
        treatment    Varchar (1080) NOT NULL ,
        summary      Varchar (256) NOT NULL ,
        created_on   Datetime NOT NULL ,
        is_active    Bool NOT NULL DEFAULT 1 ,
        id_customer  Int NOT NULL
	,CONSTRAINT tbl_follow_up_PK PRIMARY KEY (id_follow_up)

	,CONSTRAINT tbl_follow_up_tbl_customer_FK FOREIGN KEY (id_customer) REFERENCES tbl_customer(id_customer)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: tbl_time_slot
#------------------------------------------------------------

CREATE TABLE tbl_time_slot(
        id_time_slot    Int  Auto_increment  NOT NULL ,
        start_date_time Datetime NOT NULL ,
        end_date_time   Datetime NOT NULL ,
        duration_time   Datetime NOT NULL Default now(),
        notes           varchar (1000) ,
        is_active       Bool NOT NULL DEFAULT 1 ,
        is_public       Bool NOT NULL ,
        is_available    Bool NOT NULL
	,CONSTRAINT tbl_time_slot_PK PRIMARY KEY (id_time_slot)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: tbl_appointment
#------------------------------------------------------------

CREATE TABLE tbl_appointment(
        id_appointment Int  Auto_increment  NOT NULL ,
        created_on     Datetime NOT NULL ,
        is_active      Bool NOT NULL ,
        is_new         Bool NOT NULL Default true ,
        is_confirmed   Bool NOT NULL Default false ,
        id_customer    Int NOT NULL ,
        id_time_slot   Int NOT NULL,
        therapist      VARCHAR(50) NOT NULL DEFAULT ''
	,CONSTRAINT tbl_appointment_PK PRIMARY KEY (id_appointment)
    ,CONSTRAINT tbl_appointment_tbl_customer_FK FOREIGN KEY (id_customer) REFERENCES tbl_customer(id_customer)
    ,CONSTRAINT tbl_appointment_tbl_time_slot_FK FOREIGN KEY (id_time_slot) REFERENCES tbl_time_slot(id_time_slot)
)ENGINE=InnoDB DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


#------------------------------------------------------------
# Table: tbl_action_token
#------------------------------------------------------------

CREATE TABLE tbl_action_token(
        id_action_token Int  Auto_increment  NOT NULL ,
        created_on      Datetime NOT NULL DEFAULT now(),
        expiration_date Datetime NOT NULL,
        is_active       Bool NOT NULL ,
        token           Varchar(36) NOT NULL ,
        action          Varchar(50) NOT NULL ,
        id_appointment  Int,
        id_user         Int
	,CONSTRAINT tbl_action_token_PK PRIMARY KEY (id_action_token)
    ,CONSTRAINT tbl_action_token_tbl_user_FK FOREIGN KEY (id_user) REFERENCES tbl_user(id_user)
    ,CONSTRAINT tbl_action_token_tbl_appointment_FK FOREIGN KEY (id_appointment) REFERENCES tbl_appointment(id_appointment)
)ENGINE=InnoDB DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


#------------------------------------------------------------
# Table: tbl_question
#------------------------------------------------------------

CREATE TABLE tbl_question(
        id_question   Int  Auto_increment  NOT NULL ,
        id_parent     Int ,
        question_fr   Varchar (300) NOT NULL ,
        question_en   Varchar (300) NOT NULL ,
        answer_type   Varchar (20) NOT NULL ,
        display_order Int NOT NULL ,
        is_active     Bool NOT NULL DEFAULT 1
	,CONSTRAINT tbl_question_PK PRIMARY KEY (id_question)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Table: tbl_response
#------------------------------------------------------------

CREATE TABLE tbl_response(
        id_response Int  Auto_increment  NOT NULL ,
        is_active   Bool NOT NULL default 1,
        response_bool Bool default null,
        response_string Varchar(300) default null,
        id_customer Int NOT NULL ,
        id_question Int NOT NULL,
        created_on DateTime NOT NULL default now()
	,CONSTRAINT tbl_response_PK PRIMARY KEY (id_response)

	,CONSTRAINT tbl_response_tbl_customer_FK FOREIGN KEY (id_customer) REFERENCES tbl_customer(id_customer)
	,CONSTRAINT tbl_response_tbl_question0_FK FOREIGN KEY (id_question) REFERENCES tbl_question(id_question)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Table: tbl_diaporama
#------------------------------------------------------------

CREATE TABLE tbl_diaporama_image(
        id_diaporama_image      INT AUTO_INCREMENT  NOT NULL ,
        is_active     BOOL NOT NULL DEFAULT 1,
        is_displayed  BOOL NOT NULL DEFAULT 0,
        display_order INT NOT NULL DEFAULT 0,
        path 		  VARCHAR(300) NOT NULL
	,CONSTRAINT tbl_diaporama_PK PRIMARY KEY (id_diaporama_image)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Table: tbl_about_information
#------------------------------------------------------------

CREATE TABLE tbl_about_information(
        id_about_information   Int  Auto_increment  NOT NULL ,
        title_fr   Varchar (300) NOT NULL ,
        title_en   Varchar (300),
        descr_fr   Varchar (10000) NOT NULL ,
        descr_en   Varchar (10000),
        is_active     Bool NOT NULL DEFAULT 1
	,CONSTRAINT tbl_about_information_PK PRIMARY KEY (id_about_information)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Inserting basic data
#------------------------------------------------------------

INSERT INTO tbl_question(id_question,id_parent,question_fr,question_en,answer_type,display_order) VALUES
(1,null,
'Avez-vous déjà consulté un autre thérapeute (Massothérapeute, Kinésithérapeute, Orthothérapeute, Physiothérapeute, Chirothérapeute, etc.)?',
'Have you ever consulted another therapist (Massage Therapist, Physiotherapist, Orthotherapist, Physiotherapist, Therapist, etc.)?',
'bool',1
),
(2,null,
'Avez-vous déjà subi une opération ou une fracture?',
'Have you ever had an operation or a fracture?',
'bool',2
),
(3,null,
'Avez-vous déjà eu un accident?',
'Have you ever had an accident?',
'bool',3
),
(4,null,
'Avez-vous déjà eu varices ou phlébite?',
'Have you ever had varicose veins or phlebitis?',
'bool',4
),
(5,null,
'Souffrez-vous de problèmes digestifs, de diabète ou d\'hypoglycémie?',
'Do you suffer from digestive problems, diabetes or hypoglycemia?',
'bool',5
),
(6,null,
'Avez-vous des problèmes cardiaques ou circulatoires (Hypertension, Hypotension, Palpitations, Infarctus, Angine, AVC)?',
'Do you have heart or circulatory problems (Hypertension, Hypotension, Palpitations, Infarction, Angina, Stroke)?',
'bool',6
),
(7,null,
'Souffrez-vous d\'athérosclérose, d\'athérosclérose ou d\'hémophilie?',
'Do you suffer from atherosclerosis, atheropathy, or hemophilia?',
'bool',7
),
(8,null,
'Avez-vous des problèmes respiratoires (Asthme, Emphysème, etc.)?',
'Do you have breathing problems (Asthma, Emphysema, etc.)?',
'bool',8
),
(9,null,
'Êtes-vous enceinte?',
'Are you pregnant?',
'bool',10
),
(10,null,
'Avez-vous un cancer?',
'Do you have cancer?',
'bool',9
),
(11,null,
'Prenez-vous des médicaments?',
'Do you take medication?',
'bool',11
),
(12,null,
'Avez-vous des allergies?',
'Do you have allergies?',
'bool',12
),
(13,null,
'Portez-vous des orthèses, verres de contact, prothèses ou autre?',
'Do you wear orthotics, contact lenses, prostheses or other?',
'bool',13
),
(14,null,
'Avez-vous des maux de tête réguliers?',
'Do you have regular headaches?',
'bool',14
),
(15,null,
'Avez-vous une alimentation saine et équilibrée?',
'Do you have a healthy and balanced diet?',
'string_multiple',15
),
(16,4,
'Quand?',
'When?',
'string',10
),
(17,6,
'Quand?',
'When?',
'string',0
),
(18,8,
'Autre',
'Other',
'string',0
),
(19,13,
'Autre',
'Other',
'string',0
),
(20,11,
'Pour quelle(s) raison(s)?',
'For what reason(s)?',
'string',0
),
(21,10,
'Lequel?',
'Wich one?',
'string',0
);

# 'bit' must be a multiple of 2
INSERT INTO tbl_permission (bit,name) VALUES
(1,   'Root'),
(2,   'Appointments-Read'),
(4,   'Appointments-Write'),
(8,   'Customers-Read'),
(16,  'Customers-Write'),
(32,  'Timeslots-Read'),
(64,  'Timeslots-Write'),
(128, 'IsEmployee'),
(256, 'MedicalSurveys-Read'),
(512, 'MedicalSurveys-Write'),
(1024, 'SiteManager');

INSERT INTO tbl_phone_type (name) VALUES
('Résidentiel'), ('Bureau'), ('Cellulaire');

INSERT INTO tbl_country (name) VALUES
('Canada'), ('États-Unis');

SET @CAD_CountryId := (select id_country from tbl_country where name = 'Canada');
SET @USA_CountryId := (select id_country from tbl_country where name = 'États-Unis');
INSERT INTO tbl_state (code,name,id_country) VALUES
	('AB','Alberta', @CAD_CountryId),
	('BC','Colombie-Britannique', @CAD_CountryId),
	('MB','Manitoba', @CAD_CountryId),
	('NB','Nouveau-Brunswick', @CAD_CountryId),
	('NL','Terre-Neuve-et-Labrador', @CAD_CountryId),
	('NT','Northwest Territories', @CAD_CountryId),
	('NS','Nouvelle-Écosse', @CAD_CountryId),
	('NU','Nunavut', @CAD_CountryId),
	('ON','Ontario', @CAD_CountryId),
	('PE','Île-du-Prince-Édouard', @CAD_CountryId),
	('QC','Québec', @CAD_CountryId),
	('SK','Saskatchewan', @CAD_CountryId),
	('YT','Yukon', @CAD_CountryId),
	('AL','Alabama', @USA_CountryId),
	('AK','Alaska', @USA_CountryId),
	('AS','American Samoa', @USA_CountryId),
	('AZ','Arizona', @USA_CountryId),
	('AR','Arkansas', @USA_CountryId),
	('CA','California', @USA_CountryId),
	('CO','Colorado', @USA_CountryId),
	('CT','Connecticut', @USA_CountryId),
	('DE','Delaware', @USA_CountryId),
	('DC','District of Columbia', @USA_CountryId),
	('FM','Federated tbl_states of Micronesia', @USA_CountryId),
	('FL','Florida', @USA_CountryId),
	('GA','Georgia', @USA_CountryId),
	('GU','Guam', @USA_CountryId),
	('HI','Hawaii', @USA_CountryId),
	('ID','Idaho', @USA_CountryId),
	('IL','Illinois', @USA_CountryId),
	('IN','Indiana', @USA_CountryId),
	('IA','Iowa', @USA_CountryId),
	('KS','Kansas', @USA_CountryId),
	('KY','Kentucky', @USA_CountryId),
	('LA','Louisiana', @USA_CountryId),
	('ME','Maine', @USA_CountryId),
	('MH','Marshall Islands', @USA_CountryId),
	('MD','Maryland', @USA_CountryId),
	('MA','Massachusetts', @USA_CountryId),
	('MI','Michigan', @USA_CountryId),
	('MN','Minnesota', @USA_CountryId),
	('MS','Mississippi', @USA_CountryId),
	('MO','Missouri', @USA_CountryId),
	('MT','Montana', @USA_CountryId),
	('NE','Nebraska', @USA_CountryId),
	('NV','Nevada', @USA_CountryId),
	('NH','New Hampshire', @USA_CountryId),
	('NJ','New Jersey', @USA_CountryId),
	('NM','New Mexico', @USA_CountryId),
	('NY','New York', @USA_CountryId),
	('NC','North Carolina', @USA_CountryId),
	('ND','North Dakota', @USA_CountryId),
	('MP','Northern Mariana Islands', @USA_CountryId),
	('OH','Ohio', @USA_CountryId),
	('OK','Oklahoma', @USA_CountryId),
	('OR','Oregon', @USA_CountryId),
	('PW','Palau', @USA_CountryId),
	('PA','Pennsylvania', @USA_CountryId),
	('PR','Puerto Rico', @USA_CountryId),
	('RI','Rhode Island', @USA_CountryId),
	('SC','South Carolina', @USA_CountryId),
	('SD','South Dakota', @USA_CountryId),
	('TN','Tennessee', @USA_CountryId),
	('TX','Texas', @USA_CountryId),
	('UT','Utah', @USA_CountryId),
	('VT','Vermont', @USA_CountryId),
	('VI','Virgin Islands', @USA_CountryId),
	('VA','Virginia', @USA_CountryId),
	('WA','Washington', @USA_CountryId),
	('WV','West Virginia', @USA_CountryId),
	('WI','Wisconsin', @USA_CountryId),
	('WY','Wyoming', @USA_CountryId);

#------------------------------------------------------------
# Creating data for tests
#------------------------------------------------------------

INSERT INTO tbl_address (physical_address, city_name, zip_code, id_state) VALUES
('382, rang saint-joseph', 'Beauceville', 'G5X2C8', (select id_state from tbl_state where name = 'Québec')),
('13140, Boul. Lacroix', 'Saint-Georges', 'G5Y6P8', (select id_state from tbl_state where name = 'Québec'));

INSERT INTO tbl_customer (sex, first_name, last_name, birth_date, occupation, id_address) VALUES
('M', 'Jessy', 'Rodrigue', '1997-02-08', 'SysAdmin', '1'),
('M', 'Yannick', 'Jacques', '1997-08-31', 'Brogrammer', '2');

INSERT INTO tbl_response(id_customer,id_question,response_bool)VALUES
(1,1,1),
(1,2,1),
(1,3,0),
(1,4,0),
(1,5,0),
(1,6,1),
(1,7,0),
(1,8,1),
(1,9,0),
(1,10,0),
(1,11,1),
(1,12,1),
(1,13,1),
(1,14,1);
INSERT INTO tbl_response(id_customer,id_question,response_string)VALUES
(1,15,'Moderatly'),
(1,16,'Il y a deux ans'),
(1,17,'Depuis 3 ans'),
(1,18,'Rien d\'autre'),
(1,19,'Beaucoup de douleur'),
(1,20,'Anxiété'),
(1,21, 'Celui là');

INSERT INTO tbl_user (id_customer, email, password, role) VALUES
(1, "jessy@rodrigue.com", "123456", 1),
(2, "yannick@jacques.com", "123456", DEFAULT);

INSERT INTO tbl_phone_number (phone, id_phone_type,id_customer) VALUES
('(418) 774-3835', 1,1),
('(418) 588-6211', 1,2),
('(418) 230-5469', 3,1),
('(418) 420-6969', 2,2),
('(418) 313-8034', 3,2);

INSERT INTO tbl_time_slot (start_date_time, end_date_time, is_public, is_available, notes) VALUES
( '2019-04-30 09:00:00', '2019-04-30 10:00:00', 1, 1, null),
( '2019-04-30 10:30:00', '2019-04-30 11:30:00', 1, 1, null),
( '2019-04-30 11:30:00', '2019-04-30 13:00:00', 0, 1, null),
( '2019-04-30 13:00:00', '2019-04-30 14:30:00', 0, 0, "Passer chercher les enfants"),
( '2019-04-30 19:00:00', '2019-04-30 20:30:00', 0, 0, "Film avec la famille"),
( '2019-04-23 15:00:00', '2019-04-23 16:00:00', 1, 1, null);

INSERT INTO tbl_appointment(created_on, is_active, is_new, id_customer, id_time_slot, therapist)
VALUES (NOW(), 1,1,1,1,''),
	   (NOW(), 1,1,1,2,'Carl'),
	   (NOW(), 1,1,1,3,'Melanie'),
	   (NOW(), 1,1,1,6,'Peut Importe');
       
INSERT INTO tbl_diaporama_image(is_active, is_displayed, display_order, path)
VALUES (1,1,1,'images/ab1.jpg'),
       (1,1,2,'images/blog1.jpg'),
       (1,0,3,'images/t3.jpg'),
       (1,1,1,'images/blog4.jpg');
       
INSERT INTO tbl_about_information(title_fr, title_en, descr_fr, descr_en, is_active)
VALUES('Vous avez mal au dos?','Suffering from back pains?','On peut vous marcher sur le dos pour faire cracker toutes les vertèbre, on vous guaranti que vous
       vous sentirez mieux après.','We\'ll walk all over your back, you\'ll feel like a new person',1),
      ('Vous avez mal à l\épaule??','Suffering from shoulder pains?','On va vous swinger le bras, vous allez voir que vous ne sentirez plus rien après',
      'We\'ll swing your arm around so much you won\'t feel a thing after',1);

