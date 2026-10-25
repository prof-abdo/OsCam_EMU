#!/bin/sh

# ==============================================
# SCRIPT : DOWNLOAD AND INSTALL Oscam_EMU (11968) + NCam #
# =====================================================================================================================
# Command: wget https://raw.githubusercontent.com/prof-abdo/OsCam_EMU/main/installer.sh -O - | /bin/sh #
# =====================================================================================================================

MY_OSCAM_IPK="enigma2-softcams-oscam-all-images_11968-emu-802-arm+mips_all.ipk"
MY_OSCAM_DEB="enigma2-softcams-oscam-all-images_11968-emu-802-arm+mips_all.deb"
MY_NCAM_IPK="enigma2-plugin-softcams-ncam_V15.8-r0_all.ipk"
MY_NCAM_DEB="enigma2-plugin-softcams-ncam-osdreambox_V15.8-r0.deb"

MY_URL="https://raw.githubusercontent.com/prof-abdo/OsCam_EMU/main"

# Correct extension mapping (old script had these swapped)
if which dpkg > /dev/null 2>&1; then
    OSCAM_FILE=$MY_OSCAM_DEB
    NCAM_FILE=$MY_NCAM_DEB
else
    OSCAM_FILE=$MY_OSCAM_IPK
    NCAM_FILE=$MY_NCAM_IPK
fi

install_pkg_file() {
    FILE="$1"
    if which dpkg > /dev/null 2>&1; then
        dpkg -i --force-overwrite "$FILE" 2>&1
    else
        opkg install --force-reinstall --force-overwrite "$FILE" 2>&1
    fi
}

echo ''
echo '************************************************************'
echo '**                         STARTED                        **'
echo '************************************************************'
echo "**     OSCam 11968-emu-802 + NCam V15.8 - prof-abdo        **"
echo "************************************************************"
echo ''

# -- 1) OSCam 11968 : local copy first, else from repo -----------
OSCAM_SRC=""
for p in "/tmp/$OSCAM_FILE" "/tmp/enigma2-softcams-oscam-all-images_11968*.ipk" \
         "/tmp/enigma2-softcams-oscam-all-images_11968*.deb" \
         "/root/enigma2-softcams-oscam-all-images_11968*.ipk" \
         "/root/enigma2-softcams-oscam-all-images_11968*.deb"; do
    for cand in $p; do
        [ -f "$cand" ] && OSCAM_SRC="$cand" && break 2
    done
done

if [ -z "$OSCAM_SRC" ]; then
    echo "Downloading $OSCAM_FILE ..."
    wget -T 10 -q "$MY_URL/$OSCAM_FILE" -O "/tmp/$OSCAM_FILE"
    [ -f "/tmp/$OSCAM_FILE" ] && OSCAM_SRC="/tmp/$OSCAM_FILE"
fi

if [ -f "$OSCAM_SRC" ]; then
    echo "Installing OSCam 11968-emu-802 ..."
    install_pkg_file "$OSCAM_SRC"
    rm -f "/tmp/$OSCAM_FILE" > /dev/null 2>&1
else
    echo "Download failed !"
fi

# -- 2) NCam (kept as optional softcam) --------------------------
echo ''
echo "Downloading $NCAM_FILE ..."
rm -f "/tmp/$NCAM_FILE" > /dev/null 2>&1
wget -T 10 -q "$MY_URL/$NCAM_FILE" -O "/tmp/$NCAM_FILE"
if [ -f "/tmp/$NCAM_FILE" ]; then
    echo "Installing NCam V15.8 ..."
    install_pkg_file "/tmp/$NCAM_FILE"
    rm -f "/tmp/$NCAM_FILE" > /dev/null 2>&1
else
    echo "NCam download failed, skipping."
fi

# -- 3) OSCam stays the active/default softcam -------------------
# NCam's postinst switches the default; put OSCam back on top.
RESTORE=""
for s in softcam.oscam softcam.oscam-master; do
    [ -e "/etc/init.d/$s" ] && RESTORE="/etc/init.d/$s" && break
done
if [ -n "$RESTORE" ]; then
    ln -sf "$RESTORE" /etc/init.d/softcam 2>/dev/null
    echo ""
    echo "Restored default softcam to $(basename "$RESTORE")."
fi

# -- Result ------------------------------------------------------
if ls /usr/bin/oscam* > /dev/null 2>&1; then
    echo ''
    echo "   >>>>   SUCCESSFULLY INSTALLED   <<<<"
    echo "   >>>>   OSCam active | NCam available in Softcam Menu <<<<"
else
    echo ''
    echo "   >>>>   INSTALLATION FAILED !   <<<<"
fi

echo ''
echo '**************************************************'
echo '**                   FINISHED                   **'
echo '**************************************************'

exit 0

# ------------------------------------------------------------------------------------------------------------
