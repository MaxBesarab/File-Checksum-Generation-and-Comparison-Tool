#!/bin/bash

# Author           : Max
# Created On       : 10.04.2021
# Last Modified By : Max
# Last Modified On : 12.05.2021
# Version          : v2.0
#
# Description      :
# Program for generating and comparing md5 and sha1 checksum
#
# Licensed under GNU GPL


#show help

option(){
	menu=("Tworzenie skrotu md5" "Tworzenie skrotu sha1" "Sprawdzanie poprawnosci pliku" "Wyszukiwanie duplikatow plikow" "Tworzenie skrotow do plikow w katalogu" "Koniec")
	odp=$(zenity --list --column=Menu "${menu[@]}" --width 450 --height 350)
}

generationM(){
	FILE=$(zenity --file-selection)
	if [[ $? == 1 ]]
	then
		zenity --info --title="Błąd" --text="Musisz pomyśleć o tym, co klikasz!"
	else
		#generowanie MD5
		MD5=$(md5sum -b $FILE|awk '{print toupper($1)}')
		zenity --info --title="Twoja suma kontrolna" --text="$MD5"
		echo "$MD5"
	fi
}

generationS(){
	FILE=$(zenity --file-selection)
	if [[ $? == 1 ]]
	then
		zenity --info --title="Błąd" --text="Musisz pomyśleć o tym, co klikasz!"
	else
		#generowanie SHA1
		SHA1=$(sha1sum -b $FILE|awk '{print toupper($1)}')
		zenity --info --title="Twoja suma kontrolna" --text="$SHA1"
		echo "$SHA1"
	fi
}

verification(){
	#porównanie wprowadzonego skrótu z hashem wybranego pliku
	#pobierz ścieżkę do pliku
	FILE=$(zenity --file-selection)
	if [[ $? == 1 ]]
	then
		zenity --info --title="Błąd" --text="Musisz pomyśleć o tym, co klikasz!"
		return
	fi
	#pobierz hash do porównania
	HASH=$((zenity --entry --title="Wprowadź sumę kontrolną" --text="Wpisz tutaj swój hash ")|awk  '{print toupper($1)}')
	if [[ $? == 1 ]]
	then
		zenity --info --title="Błąd" --text="Musisz pomyśleć o tym, co klikasz!"
		return
	fi
	#pobierz typ skrótu
	ODP=$(zenity --list   --title="Wybierz typ skrótu" --column="HASH" "MD5" "SHA1")
	if [[ $? == 1 ]]
	then
		zenity --info --title="Błąd" --text="Musisz pomyśleć o tym, co klikasz!"
		return
	fi
	if [[ $ODP = "MD5" ]]
	then
		#generowanie MD5
		MD5=$(md5sum -b $FILE|awk '{print toupper($1)}')
		#zwracanie wyniku porównania
		if [[ $MD5 = $HASH ]]
		then
			zenity --info --title="Twoja suma kontrolna" --text="To ten sam plik"
			echo "True"
		else
			zenity --info --title="Twoja suma kontrolna" --text="Sumy kontrolne nie są zgodne"
			echo "False"
		fi
	elif [[ $ODP = "SHA1" ]]
	then
		#generowanie SHA1
		SHA1=$(sha1sum -b $FILE|awk '{print toupper($1)}')
		echo "$SHA1"
		if [[ $SHA1 = $HASH ]]
		then
			zenity --info --title="Twoja suma kontrolna" --text="To ten sam plik"
			echo "True"
		else
			zenity --info --title="Twoja suma kontrolna" --text="Sumy kontrolne nie są zgodne"
			echo "False"
		fi
	elif [[ $? == 1 ]]
	then
		zenity --info --title="Błąd" --text="Musisz pomyśleć o tym, co klikasz!"
	fi
}

duplicate(){
	KATALOG=$(zenity --file-selection --directory)
	readarray -t arr < <(find . $KATALOG -maxdepth 1 -type f -exec md5sum {} + | sort)
	# zapętlić tablicę i porównać sumę md5 ciągłych elementów
	for i in "${arr[@]}"
	 do
	  md5="${i/ */}"
	  [[ "$md5" = "$prev_md5" ]] && printf '%s\n' "$prev_i" "$i" | zenity --text-info --width 800 --height 700 --title "Duplikaty:"
	  prev_md5="$md5"
	  prev_i="$i"
	done | sort -u
}

hashDirectory(){
	ODP=$(zenity --list   --title="Wybierz typ skrótu" --column="HASH" "MD5" "SHA1")
	if [[ $? == 1 ]]
	then
		zenity --info --title="Błąd" --text="Musisz pomyśleć o tym, co klikasz!"
		return

	elif [[ $ODP = "MD5" ]]
	then
		hash="md5sum"
		
	elif [[ $ODP = "SHA1" ]]
	then
		hash="sha1sum"
    fi
	KATALOG=$(zenity --file-selection --directory)
	readarray -t arr < <(find . $KATALOG -maxdepth 1 -type f -exec $hash {} + | sort)
	printf "%s\n" "${arr[@]}" | zenity --text-info --width 800 --height 700 --title "Lista plikow & hash"
}

if [[ $1 = "-h" ]]
then
	echo -e "-h - pomoc \n-v - pokaż informacje o autorze i wersji programu \n-g - otwórz okno dialogowe, które daje możliwość zrobienia skrótu pliku"
	exit 0
	
#pokaż wersję i autora
elif [[ $1 = "-v" ]]
then
	echo -e "Autor: Max\nProgram version 0.1"
	exit 0

elif [[ $1 = "-g" ]]
then
	ODP=$(zenity --list   --title="Wybierz typ skrótu" --column="HASH" "MD5" "SHA1")
	if [[ $? == 1 ]]
	then
		zenity --info --title="Błąd" --text="Musisz pomyśleć o tym, co klikasz!"
	elif [[ $ODP = "MD5" ]]
	then
		generationM
	elif [[ $ODP = "SHA1" ]]
	then
		generationS
	fi

elif [[ $1 = "" ]]
then
	while [[ $odp != "Koniec" ]]
	do
	option
	if [[ $odp == "Tworzenie skrotu md5"* ]]
	then
		generationM
	elif [[ $odp == "Tworzenie skrotu sha1"* ]]
	then
		generationM
	elif [[ $odp == "Sprawdzanie poprawnosci pliku"* ]]
	then
		verification
	elif [[ $odp == "Wyszukiwanie duplikatow plikow"* ]]
	then
		duplicate
	elif [[ $odp == "Tworzenie skrotow do plikow w katalogu"* ]]
	then
		hashDirectory
	fi
	done

else
	echo "Zły parametr. Użyj -h, aby zobaczyć dostępne parametry "
	exit 0
fi
