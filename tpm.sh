#Create Platform Key
uuidgen --random > GUID.txt
openssl req -newkey rsa:2048 -nodes -keyout PK.key -new -x509 -sha256 -days 3650 -subj "/CN=my Platform Key/" -out PK.crt
openssl x509 -outform DER -in PK.crt -out PK.cer
cert-to-efi-sig-list -g "$(< GUID.txt)" PK.crt PK.esl
sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt PK PK.esl PK.auth
#Create Key Exchange Key
openssl req -newkey rsa:2048 -nodes -keyout KEK.key -new -x509 -sha256 -days 3650 -subj "/CN=my Key Exchange Key/" -out KEK.crt
openssl x509 -outform DER -in KEK.crt -out KEK.cer
cert-to-efi-sig-list -g "$(< GUID.txt)" KEK.crt KEK.esl
sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt KEK KEK.esl KEK.auth
#Creating Signature Database Key
openssl req -newkey rsa:2048 -nodes -keyout db.key -new -x509 -sha256 -days 3650 -subj "/CN=my Signature Database key/" -out db.crt
openssl x509 -outform DER -in db.crt -out db.cer
cert-to-efi-sig-list -g "$(< GUID.txt)" db.crt db.esl
sign-efi-sig-list -g "$(< GUID.txt)" -k KEK.key -c KEK.crt db db.esl db.auth



objcopy \
	--add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
	--add-section .cmdline=cmdline.txt --change-section-vma .cmdline=0x30000 \
	--add-section .linux="/boot/vmlinuz" --change-section-vma .linux=0x40000 \
	--add-section .initrd="/boot/initrd.img" --change-section-vma .initrd=0x3000000 \
	/usr/lib/systemd/boot/efi/linuxx64.efi.stub /boot/EFI/BOOT/BOOTX64.EFI
sbsign --key ${SBKEYS}/db.key --cert ${SBKEYS}/db.crt --output /boot/EFI/BOOT/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI
