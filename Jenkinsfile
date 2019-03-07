pipeline {
	//here we select only docker build agents
	agent {dockerfile true} 	  
	
            //docker {
                //image 'webratio/ant:latest' //container will start from this image
		 // image 'frekele/ant'
            //}
        //}  

options {
    buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }
    
    stages{ // The content in this Jenkinsfile has the targeted keywords we will use in automation to track stages for dashboarding.
          // Please insure to at least leave these keywords inside the "stage" in your description of the activity to help keep clean
          // our automation processes
	 stage ('Initialize') {
            steps {
              echo "Initialize"
            }
	 }
		 
		 
	stage('Build') {    
      		steps {
        	echo "Build Processes  Any assembly activities that chains source together, if doesnt apply please leave a 'not applicable' echo"
        	sh "ant -buildfile FIF_nightly_build.xml"
      		}
        }      
    
    
    } // stages
} //pipeline
