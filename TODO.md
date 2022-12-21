# TODO

### Windows EZTools tomls

 
    + Eviter les regexes qui se basent sur '\\' dans le field file  car par
      compatible Linux.
      Avec la suppression de l'extract de la source machine name depuis le
      field file, il ne devrait plus y en avoir bcp, donc on pourra traiter au
      cas par cas. Et si jamais il doit effectivement rester ce genre de regex,
      on pourra plutôt faire un match sur '\\' ou '/' (pour compatibilité
      Windows + Linux).

  - Rajouter du parsing pour les outputs JSON des tools suivants, en laissant
    le CSV mais en rajoutant des
    <TOOL>_<ARTEFACT>_json_input -> <TOOL>_<ARTEFACT>_json_parser puis en
    mettant 2 inputs pour les components suivants
        JLECmd.exe
        LECmd.exe
        MFTECmd.exe
        PECmd.exe
        RecentFileCacheParser.exe
        RECmd.exe
 
    En cas d'erreur de parsing du JSON, on pourra regarder ensemble, sans doute
    en demandant sur le Discord Vector.
    Un avantage en plus du JSON versus CSV est le casting implicite des fields.

 - Update avec le nouveau header
     Vector_Windows_EZTools_AmcacheParser_Amcache-Program-Entries
