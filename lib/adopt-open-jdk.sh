# Detect product
j2se_detect_open_j2sdk=open_j2sdk_detect
open_j2sdk_detect() {
  j2se_release=0

  # JDK 11 release candidate (OpenJDK11U-jdk_x64_linux_hotspot_11_28.tar.gz)
  if [[ $archive_name =~ OpenJDK11U-jdk_x64_linux_hotspot_11([\.0-9]+)_([0-9]+)\.tar\.gz ]]
  then
      j2se_release=11
      j2se_update="${BASH_REMATCH[1]}"
      j2se_build="${BASH_REMATCH[2]}"
      j2se_arch="x64"
      j2se_version_name="${j2se_release}${j2se_update} version ${j2se_release}+${j2se_build}"
      j2se_version="${j2se_release}${j2se_update}+${j2se_build}${revision}"
      j2se_expected_min_size=180 #Mb
      j2se_binary_subdir="/bin"
      open_no_man_jre_bin_jre="jaotc jar jarsigner java javac javadoc javap jcmd jconsole jdb jdeprscan jdeps jhsdb jimage jinfo jjs jlink jmap jmod jps jrunscript jshell jstack jstat jstatd keytool pack200 rmic rmid rmiregistry serialver unpack200"
      open_bin_jdk=" "
      open_jre_bin_hl=" "
      open_jre_bin_jre=" "
  fi

  # Open JDK 8 release candidate (OpenJDK8U-jdk_x64_linux_hotspot_8u181b13.tar.gz)
  if [[ $archive_name =~ OpenJDK8U-jdk_x64_linux_hotspot_8([a-z][0-9]+)([a-z][0-9]+)\.tar\.gz ]]
  then
    j2se_release=8
    j2se_update=${BASH_REMATCH[1]}
    j2se_build=${BASH_REMATCH[2]}
    j2se_arch=x64
    j2se_version_name="${j2se_release} version ${j2se_release}${j2se_update}"
    j2se_version="${j2se_release}${j2se_update}${j2se_build}${revision}"
    j2se_expected_min_size=75 #Mb
    j2se_binary_subdir="/bin"
    open_no_man_jre_bin_jre="appletviewer extcheck idlj jar jarsigner java javac javadoc javah javap java-rmi.cgi jcmd jconsole jdb jdeps jhat jinfo jjs jmap jps jrunscript jsadebugd jstack jstat jstatd keytool native2ascii orbd pack200 policytool rmic rmid rmiregistry schemagen serialver servertool tnameserv unpack200 wsgen wsimport xjc"
    open_bin_jdk=" "
    open_jre_bin_hl=" "
    open_jre_bin_jre=" "
  fi

  if [[ $j2se_release > 0 ]]
  then
    j2se_priority=$((310 + $j2se_release))
    j2se_expected_min_size=${j2se_expected_min_size:-180} #Mb

    # check if the architecture matches
    let compatible=1

    case "${DEB_BUILD_ARCH:-$DEB_BUILD_GNU_TYPE}" in
      i386|i486-linux-gnu)
        if [[ "$j2se_arch" != "i586" ]]; then compatible=0; fi
        ;;
      amd64|x86_64-linux-gnu)
        if [[ "$j2se_arch" != "x64" && "$j2se_arch" != "amd64" ]]; then compatible=0; fi
        ;;
    esac

    if [[ $compatible == 0 ]]
    then
      echo "The archive $archive_name is not supported on the ${DEB_BUILD_ARCH} architecture"
      return
    fi


    cat << EOF

Detected product:
    Java(TM) Development Kit (JDK)
    Standard Edition, Version $j2se_version_name
    AdoptOpenJDK builds
EOF
    if read_yn "Is this correct [Y/n]: "; then
      j2se_found=true
      j2se_required_space=$(( $j2se_expected_min_size * 2 + 20 ))
      j2se_vendor="adoptopenjdk"
      j2se_title="Java Platform, Standard Edition $j2se_release Development Kit"

      j2se_install=open_j2sdk_install
      j2se_remove=open_j2sdk_remove
      j2se_jinfo=open_j2sdk_jinfo
      j2se_control=open_j2sdk_control
      open_jre_bin_hl="${open_jre_bin_hl:-java javaws keytool orbd pack200 rmid rmiregistry servertool tnameserv unpack200 policytool}"
      open_jre_bin_jre="${open_jre_bin_jre:-javaws policytool}"
      if [ "${DEB_BUILD_ARCH:0:3}" != "arm" ]; then
        open_no_man_jre_bin_jre="${open_no_man_jre_bin_jre:-ControlPanel jcontrol}"
      fi
      open_jre_lib_hl="jexec"
      open_bin_jdk="${open_bin_jdk:-appletviewer extcheck idlj jar jarsigner javac javadoc javah javap jcmd jconsole jdb jdeps jhat jinfo jmap jmc jps jrunscript jsadebugd jstack jstat jstatd native2ascii rmic schemagen serialver wsgen wsimport xjc}"
      j2se_package="$j2se_vendor-java$j2se_release-jdk"
      j2se_binary_subdir="${j2se_binary_subdir:-/jre/bin}"
      j2se_run
    fi
  fi
}

open_j2sdk_install() {
    cat << EOF
if [ ! -e "$jvm_base$j2se_name/debian/info" ]; then
    exit 0
fi

install_alternatives $jvm_base$j2se_name${j2se_binary_subdir} $open_jre_bin_hl
install_alternatives $jvm_base$j2se_name${j2se_binary_subdir} $open_jre_bin_jre
if [ -n "$open_no_man_jre_bin_jre" ]; then
    install_no_man_alternatives $jvm_base$j2se_name${j2se_binary_subdir} $open_no_man_jre_bin_jre
fi
install_no_man_alternatives $jvm_base$j2se_name/jre/lib $open_jre_lib_hl
install_alternatives $jvm_base$j2se_name/bin $open_bin_jdk

EOF
}

open_j2sdk_remove() {
    cat << EOF
if [ ! -e "$jvm_base$j2se_name/debian/info" ]; then
    exit 0
fi

remove_alternatives $jvm_base$j2se_name${j2se_binary_subdir} $open_jre_bin_hl
remove_alternatives $jvm_base$j2se_name${j2se_binary_subdir} $open_jre_bin_jre
if [ -n "$open_no_man_jre_bin_jre" ]; then
    remove_alternatives $jvm_base$j2se_name${j2se_binary_subdir} $open_no_man_jre_bin_jre
fi
remove_alternatives $jvm_base$j2se_name/jre/lib $open_jre_lib_hl
remove_alternatives $jvm_base$j2se_name/bin $open_bin_jdk

EOF
}

open_j2sdk_jinfo() {
    cat << EOF
name=$j2se_name
priority=${priority_override:-$j2se_priority}
section=main
EOF
    jinfos "hl" $jvm_base$j2se_name${j2se_binary_subdir}/ $open_jre_bin_hl
    jinfos "jre" $jvm_base$j2se_name${j2se_binary_subdir}/ $open_jre_bin_jre
    if [ -n "$open_no_man_jre_bin_jre" ]; then
        jinfos "jre" $jvm_base$j2se_name${j2se_binary_subdir}/ $open_no_man_jre_bin_jre
    fi
    jinfos "hl" $jvm_base$j2se_name/jre/lib/ $open_jre_lib_hl
    jinfos "jdk" $jvm_base$j2se_name/bin/ $open_bin_jdk
}

open_j2sdk_control() {
    build_depends="libasound2, libgl1-mesa-glx, libgtk2.0-0, libxslt1.1, libxtst6, libxxf86vm1"
    j2se_control
    depends="\${shlibs:Depends}"
    if [ "$create_cert_softlinks" == "true" ]; then
        depends="$depends, ca-certificates-java"
    fi
    for i in `seq 5 ${j2se_release}`;
    do
        provides_runtime="${provides_runtime} java${i}-runtime,"
        provides_headless="${provides_headless} java${i}-runtime-headless,"
        provides_sdk="${provides_sdk} java${i}-sdk,"
    done
    cat << EOF
Package: $j2se_package
Architecture: $j2se_debian_arch
Depends: \${misc:Depends}, java-common, $depends
Recommends: netbase
Provides: java-virtual-machine, java-runtime, java2-runtime, $provides_runtime java-compiler, java2-compiler, java-runtime-headless, java2-runtime-headless, $provides_headless java-sdk, java2-sdk, $provides_sdk
Description: $j2se_title
 The Java(TM) SE JDK is a development environment for building
 applications, applets, and components that can be deployed on the
 Java(TM) platform.
 .
 The Java(TM) SE JDK software includes tools useful for developing and
 testing programs written in the Java programming language and running
 on the Java platform. These tools are designed to be used from the
 command line. Except for appletviewer, these tools do not provide a
 graphical user interface.
 .
 This package has been automatically created with java-package ($version).
EOF
}
