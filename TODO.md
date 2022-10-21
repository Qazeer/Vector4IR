# TODO

### Windows EZTools tomls

  - 1 fichier par artefact avec comme nomemclature de nommage : 
    Vector_Windows_EZTools_<TOOL>_<ARTEFACT>.toml. Pas mal de changements style
    coding style dans cette TODO, donc à faire en dernier :)

    Puis push les fichiers sur le repo GitHub Vector_configs_IR.
  
  - Nommer les components comme suit
      -> <TOOL>_<ARTEFACT>_<csv | json>_input

      -> <TOOL>_<ARTEFACT>_<csv | json>_parser
      
      # Pour timeline uniquement
      -> <TOOL>_<ARTEFACT>_dedup_<FIELD>
      
      # En amont du ELK sink uniquement - si besoin, voir le point sur le field @timestamp / timestamp.
      -> <TOOL>_<ARTEFACT>_ELK_add_fields
      
      -> <TOOL>_<ARTEFACT>_<blackhole | console | ELK | Splunk>_sink
    
  
  - Mettre tous les fields en lowercase, ca simplifie les recherches imo et
    c'est le standard Splunk.
    
    Exemple :
    .ParentPath = fields[5] -> .parentpath = fields[5]
    .FileName = fields[6] -> .filename = fields[6]
  
  - Mettre des '/' au lieu des '\\' dans les inputs, pour compatibilité Linux.
    
    Exemple :
    "[...]\\*MFT_Output.csv" -> "[...]/*MFT_Output.csv"

    + Eviter les regexes qui se basent sur '\\' dans le field file  car par
      compatible Linux.
      Avec la suppression de l'extract de la source machine name depuis le
      field file, il ne devrait plus y en avoir bcp, donc on pourra traiter au
      cas par cas. Et si jamais il doit effectivement rester ce genre de regex,
      on pourra plutôt faire un match sur '\\' ou '/' (pour compatibilité
      Windows + Linux).
  
  - Indentation de 2 espaces pour chaque component, et nouvelle indendation de
    2 espaces pour le VRL. Vscode est pratique pour ca, avec l'extension toml
    c'est plus pratique pour l'edit.
  
  - Mettre un "." à la fin de ligne de phrase en commentaire.
  
  - Mettre les inputs sous cette forme quand il y en a plusieurs :

      inputs = [
        "Linux_stat_timeline_dedup_crtime",
        "Linux_stat_timeline_dedup_mtime",
        "Linux_stat_timeline_dedup_ctime",
        "Linux_stat_timeline_dedup_atime"
      ]
  
  - Mettre les 4 sinks systématiquement : blackhole, console, elasticsearch,
    et splunk_hec_logs (mais tous en commentaire).

    Commentaires d'entêtes pour les sinks :

    # Sink to send processed logs to void, for validating that the pipeline doest not raise errors.

    # Sink to send processed logs to the console for debugging.
    
    # Sink transform to send processed logs to an ELK instance.
    
    # Sink transform to send processed logs to a Splunk instance.
    
    Le fait d'avoir des variables d'env required pour ELK / Splunk va empêcher
    l'exec même si en commentaire, mais une issue a déjà été crée pour ca côté
    Vector et un patch devrait bientôt sortir.

  - Mettre le header de meta données en commentaire en début de chaque fichier:
  
      # Vector_Windows_EZTools_MFTECmd_MFT config.
      # Description: Process Windows MFT artefacts parsed with MFTECmd (CSV output).
      #              Filename should match: "*MFTECmd_$MFT_Output*.csv"
      #              MFTECmd command: XXX
      # Author(s): Jérôme BREBION, Thomas DIOT (_Qazeer)
      # Version: 1.0
      # Last modified: 2022-09-01
      # Required environment variables:
      #   INPUT_FOLDER = "<INPUT_FOLDER>"
      #   VECTOR_TEMP_FOLDER = "<VECTOR_TEMP_FOLDER>"
      #   INDEX = "<INDEX>"
      #   SOURCE_HOST = "<SOURCE_HOST>"
      #   -- ELK sink specific variables. ELK index = <INDEX> & source = windows_mft & sourcetype = windows_artefact (windows_event pour evtx).
      #   ELK_IP = "<IP>"
      #   ELK_PORT = "<PORT>" -- ELK bulk HTTP API port. Defaults to 9200.
      #   ELK_USERNAME = "<USERNAME>"
      #   ELK_PASSWORD = "<PASSWORD>"
      #   -- Splunk sink specific variables. Splunk index = <INDEX> & source = windows_mft & sourcetype = windows_artefact (windows_event pour evtx).
      #   SPLUNK_IP = "<IP>"
      #   SPLUNK_PORT = "<PORT>" -- Splunk HTTP Event Collector port. Defaults to 8088.
      #   SPLUNK_HEC_TOKEN = "<SPLUNK_HEC_TOKEN>" -- Splunk HEC token: https://docs.splunk.com/Documentation/Splunk/9.0.1/Data/UsetheHTTPEventCollector.

  - Remettre dans chaque fichiers le Vector data dir :
  
      # Temporary folder used by Vector.
      data_dir = "${VECTOR_TEMP_FOLDER:?A directory for Vector temporary data is required}"
   
  - Variable INPUT_FOLDER : 
    "${INPUT_FOLDER:?The input folder containing the XXX files is required. Add '**' to process the specified folder recursively (exemple: \"C:\\logs\" or folder \"C:\\logs\\**\")}
  
  - Renommage de variable d'environnement:
      
      CASE -> INDEX (car plus d'index spécifique, toujours le même : rajout des fields source et sourcetype)
      HELK_* -> ELK_*
      WORK_DIRECTORY -> INPUT_FOLDER
      VECTOR_TEMP -> VECTOR_TEMP_FOLDER

      New:
      SOURCE_HOST, SPLUNK_IP, SPLUNK_PORT, SPLUNK_HEC_TOKEN
  
  - Mettre en valeur par défaut 9200 pour ELK_PORT et 8088 pour SPLUNK_PORT
      "http://${ELK_IP:?ELK IP is required}:${ELK_PORT:-9200}"
      "http://${SPLUNK_IP:?Splunk IP is required}:${SPLUNK_PORT:-8088}"
  
  - Maj le message d'erreur en cas d'absence de variable d'env INPUT_FOLDER pour
    correspondre à l'artefact.
    
    Exemple : 
    "${INPUT_FOLDER:?The input folder containing the Zimbra access log files is required}
    "${INPUT_FOLDER:?The input folder containing the MFTECmd output files is required}
  
  - Suppression du parsing de la machine name via le folder, spécification
    directement du nom de la machine via env var SOURCE_HOST (voir point
    suivant).

  - Rajouter dans le remap de parsing les fields sourcehost, host, source, et
    sourcetype. .source remplace .Artefact

    Les sets aussi directement dans le sink Splunk (ces fields sont par défaut
    et obligatoires dans Splunk, c'est pour être cohérent entre les deux).

    Donc on peut retirer le 
      # Delete useless default fields
      del(.host)
      del(.source_type)
      del(.timestamp)
      del(.file)
    
    Pour laisser (le del uniquement si le file n'est pas automatiquement
    supprimé par un . = [...] ou ., err = [...]):
      # Delete irrelevant default fields
      del(.file)
      
      # Add the metadata fields following the parsing.
      .sourcehost = "${SOURCE_HOST:?The source host is required}"
      .host = .sourcehost
      .source = "windows_<LOWERCASE_ARTEFACT>" # Exemple source: windows_mft / windows_usnjrnl / windows_registry / windows_prefect
      .sourcetype = "windows_artefact" / "windows_event" (pour EVTX)
    
    + splunk sink:
      host_key = "host"
      source = "{{ source }}"
      sourcetype = "{{ sourcetype }}"

  - Checker si .timestamp passe pour ELK et non .@timestamp, car Splunk a
    besoin de .timestamp. Si .@timestamp est bien requis par ELK, rajouter un
    remap spécifique pour move le field .timestamp en .@timestamp.

  - Rajouter un field operation et suboperation pour le timelining,
    en lowercase.
    Exemple pour MFT: 
      MFTECmd_MFT_dedup_LastModified0x10
        .operation = "file_modification"
        .suboperation = "file_modification_si"
    
    Exemple pour Prefetch:
        PECmd_Prefect_dedup_LastRun
          .operation = "execution"
          .suboperation = "execution_lastrun"
        
        PECmd_Prefect_dedup_PreviousRun1
          .operation = "execution"
          .suboperation = "execution_previousrun1"

  - Des qu'il y a un parsing de regex, mettre un commentaire d'explication,
    donnant le format attendu du field.
    
    Exemple :
       # Parse XXX field to extract YYY. Expect format: ZZZ.
       parse_regex(fields[25], r'^(?P<time>.*)\.(?P<nano>.*)$')."time"
  
  - Utiliser parse timestamp avec un format spécifique plutôt que d'utiliser
    une regex pour extraire le timestamp puise le parser avec to_timestamp.
    Il y a dans la doc Vector un link vers strtime et les formats supportés.

    Exemple :
      tmp_timestamp, err = parse_timestamp(XXX, format: "%Y-%m-%d %H:%M:%S.%f %z")
      if (err != null) {
          XXX = tmp_timestamp
      }

  - Mettre 1 ligne de commentaire avant le parsing de CSV qui donne le header attendu:
    # Expect CSV header:
    # AAA,BBB,CCC,...,XXX,YYY,ZZZ

    Comme ca si l'output du tool change, on pourra voir assez vite ce qui a été
    rajouté / modifié / supprimé.

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

  - Ajout d'une pipeline pour un JSON produit par winlogbeat. Je (TDO) pourrais
    regarder ca semaine pro.

  New TODO :
  
  - Rajouter les extract de tests, sous le format Windows_EZTools_TOOL_ARTEFACT.csv
      Ex: Windows_EZTools_AmcacheParser_Amcache_AssociatedFileEntries
  
  - Parsing de timestamp sous ce format:
      if (fields[3] != null && fields[3] != "" && fields[3] != "\r") {
        # Parse LastModifiedTimeUTC field to extract timestamp. Input format: YYYY-MM-DD hh:mm:ss.zzz. Expected format: YYYY-MM-DD hh:mm:ss.
        .lastmodifiedtimeutc, err = parse_timestamp(fields[3], format: "%Y-%m-%d %H:%M:%S.%f")
        if err != null {
          log("[Amcache_ProgramEntries] Unable to parse LastModifiedTimeUTC timestamp: " + err, level: "error")
        }
      }

 - Faire du coerce en bool: to_bool
 
 - Suppr les assignements d'err si pas de check fait dessus.
     Ex si pas de check sur err: value, err = to_int(abc) => value = to_int!(abc)

 - Update avec le nouveau header
     Vector_Windows_EZTools_AmcacheParser_Amcache-Program-Entries
   