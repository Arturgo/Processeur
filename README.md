# Processeur
Projet de système numérique pour l'ENS, par Arthur Léonard et Étienne Rossignol.

## Simulateur :
Pour utiliser le simulateur, il faut aller dans le dossier Comp++/, puis compiler :
```sh g++ -o main main.cpp -Wall -std=c++11 -O2 ```

Ensuite, dans le dossier Comp++/Tests, pour compiler test.net exécutez (Ne pas faire attention à ce qui est affiché) :
```sh ./compile.sh test.net ```

Vous pouvez enfin lancer l'exécutable pour lancer le netlist :
```sh ./proc ```

Il va demander combien de ticks s'exécuter, ainsi que des chemins vers des fichiers pour initialiser les rams. Mettre un fichier vide remplira la ram avec des zéros.





## Processeur :
Une première version du processeur est disponnible, avec une interface graphique.

Pour le tester, commencez par installer la SFML :
```sh sudo apt-get install libsfml-dev ```

Compilez Comp++ en exécutant dans le dossier Comp++/ :
```sh g++ -o main main.cpp -Wall -std=c++11 -O2 ```

Puis aller dans OurJazz/Build, et exécuter test.sh :
```sh ./test.sh ```

Cela peut prendre un certain temps, puisque GCC doit compiler plusieurs milliers de lignes en sortie du transpiler netlist.

Vous pouvez maintenant exécuter le processeur sur le programme :
```sh echo "../Tests/div.data" | ./proc ```

L'assembleur du programme correspondant est le fichier 
```sh /asm/Tests/div.s ```



## Assembleur :
Si vous voulez utiliser votre propre programme sur notre processeur, vous pouvez écrire votre assembleur dans un fichier .s dans /asm/Tests/.

Pour le transformer en un fichier de données, exécutez :
```sh python3 assembleur.py Tests/votre-fichier-assembleur.s > ../OurJazz/Tests/votre-fichier-assembleur.data ```

Cette commande va créer un fichier .data qui contient des bits qui représentent votre programme.

Dans /OurJazz/Build, après avoir lancé test.sh pour compiler le processeur, vous pouvez lancer le processeur sur votre programme :
```sh echo "../Tests/votre-fichier-assembleur.data" | ./proc ```

Ainsi, le processeur va être lancé avec votre programme dans sa RAM.
Une fenêtre va s'ouvrir, qui est l'interface graphique du processeur.

Actuellement, elle supporte :
-L'affichage de pixels en RGBA
-Une interface rudimentaire pour le clavier
-Une synchronisation avec le temps de l'ordinateur
