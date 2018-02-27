#!/bin/zsh

UXA_CONFIG="$WORKSPACE/mousetest/app/config/parameters.dev.yml"
PP_CONFIG="$WORKSPACE/project-parameters/conf/env.json"
CAF_CONFIG="$WORKSPACE/cs-app-feature/conf/env.json"

environnements=(dev future next1 next2 next3 next4 next5 staging Quit)
select opt in "${environnements[@]}"
do
    case $opt in
        "dev"|"future"|"next1"|"next2"|"next3"|"next4"|"next5"|"staging")

            # UXA
            APP_CONF_UXA="$WORKSPACE/app-conf/uxanalytics/$opt/eu-west-1/parameters.yml"
            uxa_lines=('database_host' 'database_name' 'database_user' 'database_password' 'env_prefix')
            for line in $uxa_lines; do
              line_appconf=`cat $APP_CONF_UXA | grep -m1 "$line.*:"`
              if [ -n "$line_appconf" ]; then
                vim -c "g/$line.*:/s/^.*/$line_appconf" -c "wq" $UXA_CONFIG
              else
                echo "No line in $UXA_CONFIG for : $line";
              fi
            done

            # PROJECT-PARAMETERS
            APP_CONF_PP="$WORKSPACE/app-conf/project-parameters/$opt/eu-west-1/env.json"
            pp_lines=('host' 'database' 'username' 'password')
            for line in $pp_lines; do
              line_appconf=`cat $APP_CONF_PP | grep -v "{" | grep -m1 "$line.*:"`
              if [ -n "$line_appconf" ]; then
                vim -c "g/\v^(.*$line.*:)&(.*\{)@!/s/^.*/$line_appconf" -c "wq" $PP_CONFIG
              else
                echo "No line in $PP_CONFIG for : $line";
              fi
            done


            # CS-APP-FEATURE (HPG)
            APP_CONF_CAF="$WORKSPACE/app-conf/cs-app-feature/$opt/eu-west-1/env.json"
            caf_lines=('hpg-replay' 'hpgm-mapping' 'hpgm-screengraph' 'hpgm-zoning')
            for line in $caf_lines; do
              line_appconf=`cat $APP_CONF_CAF | grep $line -A1 | grep -m1 "url.*:"`
              if [ -n "$line_appconf" ]; then
                # the line_appconf needs to escape slash
                vim -c "g/.*$line.*:/+s/^.*/${line_appconf//\//\\/}" -c "wq" $CAF_CONFIG
              else
                echo "No line in $CAF_CONFIG for : $line";
              fi
            done

            break
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done