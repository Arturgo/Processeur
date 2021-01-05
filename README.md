Lien vers le github : (https://github.com/Arturgo/Processeur)

# Processeur
Projet de système numérique pour l'ENS, par Arthur Léonard et Étienne Rossignol.

## Simulateur :

### Utilisation :
Pour utiliser le simulateur, il faut aller dans le dossier Comp++/, puis compiler :
```shell
g++ -o main main.cpp -Wall -std=c++11 -O2
```

Ensuite, dans le dossier Comp++/Tests, pour compiler un fichier netlist exécutez (Ne pas faire attention à ce qui est affiché) :
```shell
./compile.sh chemin/vers/le/fichier/netlist.net
```

Vous pouvez enfin lancer l'exécutable pour lancer le netlist :
```shell
./proc
```

Il va demander combien de ticks s'exécuter, ainsi que des chemins vers des fichiers pour initialiser les rams. Mettre un fichier vide remplira la ram avec des zéros. Un tel fichier doit contenir une succession des caractères "0" et "1".

### Story time :

Le simulateur a été codé trois fois : une première fois en OCaml (SimuML) avec la structure donnée en exemple. Cependant, la structure ne permettait pas de faire de l'évaluation paresseuse.

Une deuxième version (Simu++) a donc été codée en C++, qui était toujours un interpréteur de Netlist. Cette fois-ci, il pouvait faire de l'évaluation paresseuse et de la compression de chemin, ce qui était nécessaire au vu de la sortie du compilateur MiniJazz : il fait des CONCAT et des SPLIT qui peuvent être optimisés. On gagne ainsi un facteur en temps de l'ordre de 50 par rapport à la version précédente.

Finalement, une troisième version (Comp++) a été codée, toujours en C++, puisque la précédente version disposait déjà du parser netlist (qui est la partie qui prend le plus de temps). Cette fois-ci, afin de gagner toujours plus de temps, Comp++ transpile le netlist en C++, et demande à GCC d'optimiser l'exécutable. Les optimisations précédentes, c'est à dire l'évaluation paresseuse et la compression de chemin, ont bien sûr été conservées. On gagne ainsi un facteur en temps de l'ordre de 3 par rapport à la version précédente.

Vous ne disposez ici que de Comp++, qui est la version la plus aboutie et la plus efficace des trois.

Comme nous sommes toujours lents comparés à (par exemple) une gameboy, une éventuelle prochaine version utilisera le bit-parallelism.

## Processeur :

### Utilisation :

Une première version du processeur est disponnible, avec une interface graphique.

Pour le tester, commencez par installer la SFML :
```shell
sudo apt-get install libsfml-dev 
```

Compilez Comp++ en exécutant dans le dossier Comp++/ :
```shell
g++ -o main main.cpp -Wall -std=c++11 -O2
```

Puis aller dans OurJazz/Build, et exécuter test.sh :
```shell
./test.sh
```

Cela peut prendre un certain temps, puisque GCC doit compiler plusieurs milliers de lignes en sortie du transpiler netlist.

### Montre digitale :

Vous pouvez maintenant exécuter le processeur sur le programme :
```shell
echo "../Tests/div.data" | ./proc 
```

L'assembleur du programme correspondant est le fichier 
```shell 
/asm/Tests/div.s
```

Vous devriez obtenir quelque chose qui ressemble à ça :

![Screenshot de la montre](https://raw.githubusercontent.com/Arturgo/Processeur/main/montre.png)

### Snake :

Vous pouvez aussi profiter d'un snake exceptionnel :
```shell
echo "../Tests/snake.data" | ./proc 
```

L'assembleur du programme correspondant est dans le fichier :
```shell 
/asm/serpent.s
```

Vous devriez obtenir quelque chose qui ressemble à ça :

![Screenshot de la montre](https://raw.githubusercontent.com/Arturgo/Processeur/main/snake.png)

### L'architecture du processeur

Actuellement, le processeur supporte :
 * L'affichage de pixels en RGBA, avec synchronisation entre le processeur et l'affichage.
 * Une interface rudimentaire pour le clavier.
 * Une synchronisation avec le temps de l'ordinateur.
 * Les portes logiques suivantes : le déplacement, l'incrément, l'addition, le non logique, l'opposé arithmétique, la soustraction, le OU exclusif, le OU, le ET, la multiplication, la division, le modulo.
 * Les instructions de contrôles : saute si nul, saute si non-nul, saut si négatif, saute si strictement négatif, saute si positif, saute si strictement positif, saut inconditionel
 * L'architecture est basée sur 16 registres 32 bits, avec des instructions de 128 bits, et une RAM découpée en 4194304 mots de 128 bits.

### Story time :

Nous avons commencé par faire du miniJazz mais nous avons finalement trouvé plus pratique de coder notre propre bibliothèque en c++.

Nous avons fait le choix d'utiliser le registre rip qui donne la ligne en cours comme étant un registre presque quelconque.
Ainsi, faire des sauts nécessite des instructions spécifiques mais qui respectent la même structure que les autres instructions.

Nous avons codé la multiplication et la division. Nous voulions factoriser les instructions d'addition, soustraction... mais quand nous avons vu que la division prenait 50% des portes du processeur, nous avons jugé que ce n'était pas très utile.

## Assembleur :

### Utilisation :
Si vous voulez utiliser votre propre programme sur notre processeur, vous pouvez écrire votre assembleur dans un fichier .s dans /asm/codes/.

Pour le transformer en un fichier de données, exécutez :
```shell
python3 assembleur.py codes/votre-fichier-assembleur.s > ../OurJazz/Tests/votre-fichier-assembleur.data
```

Cette commande va créer un fichier .data qui contient des bits qui représentent votre programme.

Dans /OurJazz/Build, après avoir lancé test.sh pour compiler le processeur, vous pouvez lancer le processeur sur votre programme :
```shell
echo "../Tests/votre-fichier-assembleur.data" | ./proc
```

Ainsi, le processeur va être lancé avec votre programme dans sa RAM.
Une fenêtre va s'ouvrir, qui est l'interface graphique du processeur.

### Story time :
Pour programmer l'assembleur, nous avons voulu faire un langage basé sur du python de façon à ne pas avoir à faire d'analyse syntaxique et lexicale. Nous avons créé deux programmes python : assembleur.py qui prend le programme, le modifie un peu, en particulier en ajoutant la bibliothèque de fonctions puis l'exécute. Nous avons en parallèle programmé la bibliothèque asm.py. Le plus difficile a été de coder la fonction code qui prend en entrée les différentes informations sur une instruction puis l'affiche. Le but était de faire la fonction la plus générale possible pour rendre la suite plus simple. Ainsi, on peut lui donner des registres ou des adresses de la même manière. Les fonctions du langage ont ensuite pu être ajoutées de façon générique sans avoir à faire une ligne de code pour chacune. Nous avons ensuite gérer les labels, cela paraissait assez simple. La difficulté était qu'ils peuvent être appelés avant d'être définis. Nous avons donc exécuté le code plusieurs fois en le dupliquant pour que cela fonctionne. Nous avons finalement ajouté la possibilité de créer des variables globales et importer un code extérieur sans difficulté.
