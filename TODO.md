_______________________________________________________________________________________
# Ovdje ubacite sve sto je Vuk tokom semestra goovorio da bi bilo interesantno
_______________________________________________________________________________________

## Predavanje 10:
Umjesto pretabavanja Python ->C++ ->SystemC -> VHDL da bi se napravio DUT
	iskoristiti vec postojeci C++ i uvezati ga kako bi to iskoristili kao DUT
	
## Predavanje 11:
Preporuka koristiti ASSERT funkcije bilo gdje kako bismo znali tacno gdje
		je greska (kasnjenje pozivanja greske)
	Implementovati originalnu ISR, a ne pooling. Korisno kao dio procesor treba
		da izvrsava dio koda dok HW obradjuje nesto.
	Preporuka napraviti API za SAHE tako da koristimo C i H fajlove i korisnik
		samo poziva funkcije i ne mora da misli o adresnom prostoru!
	
## Predavanje 12:
Napravi START registar da bude AUTO-CLEAR i interrupt da bude R2C
	Implementovati potencijalno IP-XACT za opis registarske mape, registarra,
		bitfield-ova
## Predavanje 13:
Mi cesto damo najkriticniju putanju preko vivada koji to da za RTL nivo,
		njega to ne zanima vec to moramo povezati sa izvornim kodom. Sta
		je to kod na su izvornom kodu.
	Ako imamo dve periferije, jednu periferiju mozemo preko HLS alata
		modelovati
## Predavanje 14:
Ne prijavljujete FF vec LUT-ove, BRAM i DSP.
	Vukic bi najradije da mi implementujemo citav AXI4-Full interfejs,
		tho mozemo i neki drugo. Studenti vole da koriste vise 
		AXI-Stream komponenti. Trece rjesenje je preko DMA
	 
	
