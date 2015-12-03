CA_DIR := ./ca
PRIVATE_DIR := $(CA_DIR)/private
CERTS_DIR := $(CA_DIR)/certs
CSR_DIR := $(CA_DIR)/csrs
NEWCERTS_DIR := $(CA_DIR)/newcerts
CRL_DIR := $(CA_DIR)/crl
PASSWORD := topsecret

CA_CERT := $(CA_DIR)/cacert.pem
CA_KEY := $(PRIVATE_DIR)/cakey.pem

.dirs-created:
	mkdir -pm 0755 $(CA_DIR)
	mkdir -pm 0755 $(PRIVATE_DIR)
	mkdir -pm 0755 $(CERTS_DIR)
	mkdir -pm 0755 $(CSR_DIR)
	mkdir -pm 0755 $(NEWCERTS_DIR)
	mkdir -pm 0755 $(CRL_DIR)
	touch .dirs-created

ca/index.txt: .dirs-created
	touch ca/index.txt

ca/serial: .dirs-created
	echo '01' > ca/serial

$(CA_CERT) $(CA_KEY): .dirs-created | ca/serial ca/index.txt
	openssl req -config openssl.cnf \
		-new -x509 -extensions v3_ca \
		-keyout $(CA_KEY) \
		-passout pass:$(PASSWORD) \
		-out $(CA_CERT) \
		-days 10000 \
		-subj '/C=UK/O=TestOrg/CN=TestCA'

.PHONY: ca-cert
ca-cert: $(CA_CERT) $(CA_KEY)

$(CSR_DIR)/%.csr: $(PRIVATE_DIR)/%.pem .dirs-created
	cp openssl.cnf openssl-csr.cnf
	echo subjectAltName=IP:$* >>	openssl-csr.cnf
	openssl req -config openssl-csr.cnf \
		-new \
		-nodes \
		-key $< \
		-out $@ \
		-days 10000 \
		-subj /C=UK/O=TestOrg/CN=$*
	openssl req -text -noout -in $@
	rm openssl-csr.cnf

$(PRIVATE_DIR)/%.pem: .dirs-created
	openssl genpkey \
		-algorithm RSA \
		-out $@ 

$(CERTS_DIR)/%.pem: $(CSR_DIR)/%.csr $(CA_CERT) $(CA_KEY)
	yes | openssl ca -config openssl.cnf \
		-policy policy_anything \
		-out $@ \
		-passin pass:$(PASSWORD) \
		-infiles $<

.SECONDARY:

.PHONY: clean
clean:
	rm -rf ca
	rm -f .dirs-created

cert-%: 
	$(MAKE) $(CERTS_DIR)/$*.pem
	@echo
	@echo Certificate in $(CERTS_DIR)/$*.pem
	@echo Private key in $(PRIVATE_DIR)/$*.pem
