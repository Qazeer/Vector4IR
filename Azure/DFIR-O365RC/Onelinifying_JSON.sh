if [ $# -eq 0 ]
  then
    echo "[-] A file or folder to process must be specified"
    exit 1
fi

input=$1

if [[ -d $input ]]; then
    for file in $(find $input -name '*.json');
    do
        # Skip non JSON files and UnifiedAuditLog_*.json files as they are already one-line.
        if [[ $file == *UnifiedAuditLog* ]] || ! [[ $file == *json ]]; then
            continue
        fi
        echo "[*] Processing file '$file'"
        dos2unix $file
        # sed -i -e ':a' -e 'N' -e '$!ba' -e 's/\n//g' $file
        jq -c . "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        echo "[+] File onelinified!"
    done

elif [[ -f $input ]]; then
    echo "[*] Processing file '$input'"
    dos2unix $input
    # sed -i -e ':a' -e 'N' -e '$!ba' -e 's/\n//g' $input
    jq -c . "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "[+] File onelinified!"

else
    echo "[-] '$input' is not a file or folder"
    exit 1
fi