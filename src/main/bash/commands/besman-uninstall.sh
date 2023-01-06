#!/usr/bin/env bash

function __bes_uninstall {

local environment version
environment=$1
version=$2

# Condition where all the envs and its available versions will be removed
if [[ $environment == "all" && -z $version ]]; then
  
  __besman_echo_white "This operation would remove all the environments and its files"
  __besman_interactive_uninstall || return 1
  __besman_echo_white "Removing files..."
  __besman_secure_curl "https://raw.githubusercontent.com/$BESMAN_NAMESPACE/BeSman/master/dist/environments" >> $HOME/env_tmp.txt
  
  sed -i 's/,/ /g' $HOME/env_tmp.txt
  
  local curled_environment=$(cat $HOME/env_tmp.txt)
  
  for i in ${curled_environment[@]}; 
  do
  
    if [[ -d $BESMAN_DIR/envs/besman-$i ]]; then
      
      __besman_uninstall_$i "$i"
    
    fi
  
  done
  
  [ -f $HOME/env_tmp.txt ] && rm $HOME/env_tmp.txt
  
  find $BESMAN_DIR/envs -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;
  
  unset curled_environment
  
  __besman_echo_green "Files removed successfully."
# Condition where no current file is present and the user executes uninstall without version parameter

elif [[ ! -f $BESMAN_DIR/envs/besman-$environment/current && -z $version ]]; then

  __besman_echo_violet "Something went wrong"

  __besman_echo_violet "Please re-install $environment and try again"

# Condition where current file is present and the user executes uninstall to remove the current version  
elif [[ -f $BESMAN_DIR/envs/besman-$environment/current && $version == $(cat $BESMAN_DIR/envs/besman-$environment/current) ]]; then  

  __besman_echo_white "This operation would remove the current version $version for $environment"
  __besman_echo_cyan "This would leave the environment without a current"
  __besman_interactive_uninstall || return 1
  __besman_echo_no_colour "Uninstalling version $version of $environment"
  __besman_uninstall_$environment "$environment"
  [[ -f $HOME/besman-$environment.yml && -f $HOME/tmp_var_file.sh ]] && __besman_unset_env_parameters

  rm $BESMAN_DIR/envs/besman-$environment/current 
  rm -rf $BESMAN_DIR/envs/besman-$environment/$version 
  
  # To remove the folder besman-$environment if its empty
  l=$(ls $BESMAN_DIR/envs/besman-$environment)
  
  if [[ -z $l ]]; then
  
    rm -rf $BESMAN_DIR/envs/besman-$environment
  
  fi
  
  [[ -f $BESMAN_DIR/envs/besman-$environment.sh ]] && rm $BESMAN_DIR/envs/besman-$environment.sh 
 
  __besman_echo_green "Version $version for $environment has been uninstalled successfully"
 
 # 1) Current file is present and the user prompts to remove a previous version and 2) Current file is not present and the user prompts to reove a previous version 
elif [[ -f $BESMAN_DIR/envs/besman-$environment/current && $version != $(cat $BESMAN_DIR/envs/besman-$environment/current) || ! -f $BESMAN_DIR/envs/besman-$environment/current && -d $BESMAN_DIR/envs/besman-$environment/$version   ]]; then  

  __besman_echo_white "$version for $environment is not the current version"
  __besman_echo_white "The operation will still remove the files for the version."
  __besman_interactive_uninstall || return 1
  __besman_echo_no_colour "Removing files..."
 
  rm -rf $BESMAN_DIR/envs/besman-$environment/$version
 
  # To remove the folder besman-$environment if its empty
  l=$(ls $BESMAN_DIR/envs/besman-$environment)
  if [[ -z $l ]]; then
 
    rm -rf $BESMAN_DIR/envs/besman-$environment
 
  fi

  [[ -f $BESMAN_DIR/envs/besman-$environment.sh ]] && rm $BESMAN_DIR/envs/besman-$environment.sh 

  __besman_echo_green "Files removed successfully."

fi

} 



