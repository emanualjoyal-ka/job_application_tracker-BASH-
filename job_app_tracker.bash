#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATA_FILE="${SCRIPT_DIR}/job_application.csv"


if [[ ! -f "$DATA_FILE" ]] then
	printf 'company,job_title,location,applied_date,deadline\n' > "$DATA_FILE" 
fi

save_job(){
echo
echo "===== SAVE APPLIED JOB ====="

read -r -p "Company name : " company
read -r -p "Job title : " job_title
read -r -p "Location : " location
read -r -p "Applied Date(YYYY-MM-DD) : " applied_date
read -r -p "Deadline (YYYY-MM-DD, or leave empty) : " deadline

if [[ -z "$company" || -z "$job_title" ]] then
	echo
	echo "❌ Error, Company and job title are required"
	echo
	return
fi


if [[ "$company$job_title$location$applied_date$deadline" == *,* ]] then
	echo
	echo "❌ Error, Please remove commas from entries"
	echo
	return
fi

if awk -F ',' -v c="$company" -v j="$job_title" '
NR>1 {
company=tolower($1)
job=tolower($2)
gsub(/^[[:space:]]+|[[:space:]]+$/,"",company)
gsub(/^[[:space:]]+|[[:space:]]+$/,"",job)
input_company=tolower(c)
input_job=tolower(j)
if(company==input_company && job==input_job){
found=1
}
}
END{exit(found?0:1)}
' "$DATA_FILE"
then
echo
echo "⚠️  Warning : This company and job title already exists."
echo
read -r -p "Save another record anyway? (y/n) : " confirm
if [[ ! "$confirm" =~ /^[Yy]$/ ]] then
echo "Not Saved."
return
fi
fi

printf '%s,%s,%s,%s,%s\n' "$company" "$job_title" "$location" "$applied_date" "$deadline" >> "$DATA_FILE"

echo
echo "✅ Application saved successfully!"
echo
}

search_job(){
echo
echo "===== Search Application ====="
echo
read -r -p "Company name : " search_company
read -r -p "Job title : " search_job
if [[ -z "$search_company" || -z "$search_job" ]] then
echo "Please enter both company name and job title."
return
fi
awk -F ',' -v c="$search_company" -v j="$search_job" '
NR==1 {next}
{
company=tolower($1)
job=tolower($2)
input_company=tolower(c)
input_job=tolower(j)
gsub(/^[[:space:]]+|[[:space:]]+$/,"",company)
gsub(/^[[:space:]]+|[[:space:]]+$/,"",job)
gsub(/^[[:space:]]+|[[:space:]]+$/,"",input_company)
gsub(/^[[:space:]]+|[[:space:]]+$/,"",input_job)
if(company==input_company && job==input_job){
print ""
print "Application found!"
print ""
print "Company      : "$1
print "Job          : "$2
print "Location     : "$3
print "Applied Date : "$4
print "Deadline     : "($5==""?"Not provided":$5)
found=1
}
}
END {
if(!found){
print ""
print "No matching application found."
print ""
}
}
' "$DATA_FILE"
}

list_jobs(){
echo
echo "===== All Applications ====="
echo
if [[ "$(wc -l < "$DATA_FILE")" -le 1 ]] then
echo "No applications saved yet"
echo
return
fi
column -s ',' -t "$DATA_FILE"
}

while true
 do
echo
echo "=================================="
echo "    JOB APPLICATION TRACKER"
echo "=================================="
echo "1. Save an applied job"
echo "2. Search application"
echo "3. View all applications"
echo "4. Exit"
echo
read -r -p "Choose an option : " choice
case "$choice" in
1) save_job;;
2) search_job;;
3) list_jobs;;
4) echo "Goodbye"
break;;
*) echo "Invalid Option. Choose 1 or 2.";;
esac
done
