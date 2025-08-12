CREATE DATABASE GestionPlateformeStreaming
use GestionPlateformeStreaming
Create table Utilisateur (
     Id_user int primary key,
	 Nom varchar(20),
	 Email varchar(30),
	 Date_Inscription date)
Create table Film (
     Id_Film int primary key,
	 Titre varchar(40),
	 Genre varchar(20),
	 Année_Sortie date,
	 Durée int)
Create table Abonnement (
     Id_Abonnement int primary key,
	 Id_user int foreign key REFERENCES Utilisateur(Id_user),
	 Type_Abonnement varchar(20) check (Type_Abonnement in ('BASIC','STANDARD','PREMIUM')),
	 Date_Début date,
	 Date_Fin date)
Create table Historique_Visonnage (
     Id_Historique int primary key,
	 Id_user int foreign key REFERENCES Utilisateur(Id_user),
	 Id_Film int foreign key REFERENCES Film(Id_Film),
	 Date_Visionnage date)
insert into Utilisateur 
      values (02,'Amani','aa@gmail.com','2025-01-01')
	         (01,'WISSAL','wz@gmail.com','2020-10-01')
insert into Film 
      values (100,'valentino','romantic','1990-01-01',60)
insert into Abonnement 
      values (11,01,'PREMIUM','2020-10-04','2022-06-04')
insert into Historique_Visonnage
      values (200,01,100,'2021-01-15')
select* from Utilisateur
             Film,
		     Abonnement, 
			 Historique_Visonnage
--1. Listez tous les utilisateurs inscrits depuis plus d’un an.
select * from Utilisateur where Date_Inscription<= DATEADD(year,-1,Getdate())
--2. Affichez les films d’un genre spécifique, triés par année de sortie.
select * from Film where Genre='romantic' order by Année_Sortie
--3. Trouvez les utilisateurs ayant un abonnement 'Premium' dont la date de fin est dans
--moins d’un mois.
select * from Utilisateur inner join Abonnement on Utilisateur.Id_user = Abonnement.Id_user  where Type_Abonnement = 'PREMIUM' and Date_Fin<= DATEADD( month,-1, getdate()) 
--4. Affichez les utilisateurs et les films qu’ils ont visionnés au cours de la dernière semaine.
select * from Film inner join Historique_Visonnage on Film.Id_Film = Historique_Visonnage.Id_Film where Date_Visionnage>=dateadd(DAY,-7,getdate())
--5. Listez les films qui n’ont pas été visionnés par aucun utilisateur.
SELECT* from Film left join Historique_Visonnage on Film.Id_Film = Historique_Visonnage.Id_Film where Historique_Visonnage.Id_Film is null
--6. Trouvez les utilisateurs qui ont regardé plus de 10 films depuis leur inscription.
select Utilisateur.Id_user, Nom, count(Historique_Visonnage.Id_Film) as NbFilm from Utilisateur inner join Historique_Visonnage on Utilisateur.Id_user= Historique_Visonnage.Id_user group by Utilisateur.Id_user, utilisateur.Nom having count(Id_Film)>10
--7. Affichez tous les abonnements, y compris ceux des utilisateurs non enregistrés dans la
--table des visionnages.
select * from Abonnement inner join Historique_Visonnage on Abonnement.Id_user= Historique_Visonnage.Id_user
--8. Affichez tous les utilisateurs, même ceux qui n’ont pas d’abonnement.
select * from Utilisateur inner join Abonnement on Utilisateur.Id_user = Abonnement.Id_user
--9.Listez les utilisateurs qui ont regardé le même film plusieurs fois.
SELECT Utilisateur.Id_user, Utilisateur.Nom, Film.Titre, COUNT(*) AS NbVues
FROM Utilisateur 
JOIN Historique_Visonnage ON Utilisateur.Id_user = Historique_Visonnage.Id_user
JOIN Film ON Historique_Visonnage.Id_Film = Film.Id_Film
GROUP BY Utilisateur.Id_user, Utilisateur.Nom, Film.Titre
HAVING COUNT(*) > 1;

--10. Trouvez les 3 films les plus regardés au cours des 6 derniers mois.
SELECT TOP 3 Film.Titre, COUNT(*) AS NbVues
FROM Historique_Visonnage
JOIN Film ON Historique_Visonnage.Id_Film = Film.Id_Film
WHERE Historique_Visonnage.Date_Visionnage >= DATEADD(MONTH, -6, GETDATE())
GROUP BY Film.Titre
ORDER BY NbVues DESC;

--11. Identifiez les utilisateurs ayant un abonnement actif, mais n’ayant visionné aucun film.
SELECT Utilisateur.*
FROM Utilisateur 
JOIN Abonnement ON Utilisateur.Id_user = Abonnement.Id_user
LEFT JOIN Historique_Visonnage  ON Utilisateur.Id_user = Historique_Visonnage.Id_user
WHERE Abonnement.Date_Fin >= GETDATE() 
  AND Historique_Visonnage.Id_user IS NULL;

--12. Créez un utilisateur SQL avec un accès en lecture seule sur toutes les tables.
CREATE LOGIN lecteur WITH PASSWORD = 'MotDePasse123!';
CREATE USER lecteur FOR LOGIN lecteur;
EXEC sp_addrolemember 'db_datareader', 'lecteur';

--13. Accordez à un administrateur SQL le privilège de modifier les informations des films et des abonnements.
CREATE LOGIN adminFilms WITH PASSWORD = 'MotDePasse456!';
CREATE USER adminFilms FOR LOGIN adminFilms;
GRANT UPDATE, INSERT, DELETE ON Film TO adminFilms;
GRANT UPDATE, INSERT, DELETE ON Abonnement TO adminFilms;

--14. Affichez les films qui durent plus de 2 heures et ont été visionnés par des utilisateurs ayant un abonnement 'Standard'.
SELECT DISTINCT Film.*
FROM Film 
JOIN Historique_Visonnage  ON Film.Id_Film = Historique_Visonnage.Id_Film
JOIN Abonnement  ON Historique_Visonnage.Id_user = Abonnement.Id_user
WHERE Film.Durée > 120
  AND Abonnement.Type_Abonnement = 'STANDARD';

--15. Trouvez les utilisateurs ayant regardé un film d’un genre spécifique, mais n’ayant pas d’abonnement 'Premium'.
SELECT DISTINCT Utilisateur.*
FROM Utilisateur 
JOIN Historique_Visonnage  ON Utilisateur.Id_user = Historique_Visonnage.Id_user
JOIN Film ON Historique_Visonnage.Id_Film = Film.Id_Film
JOIN Abonnement  ON Utilisateur.Id_user = Abonnement.Id_user
WHERE Film.Genre = 'romantic' -- changer genre
  AND Abonnement.Type_Abonnement <> 'PREMIUM';


