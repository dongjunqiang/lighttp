CFLAGS := -DHAVE_CONFIG_H -DHAVE_VERSION_H \
	-DLIBRARY_DIR="\"/home/sknown/git/lighttpd_install/lib\"" \
	-DSBIN_DIR="\"/home/sknown/git/lighttpd_install/sbin\"" \
	-I. -I..   \
	-D_REENTRANT -D__EXTENSIONS__ -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGE_FILES  \
	-g -O2 -Wall -W -Wshadow -pedantic -std=gnu99 \

objs := array.o \
	bitset.o \
	buffer.o \
	chunk.o \
	configfile.o \
	configfile-glue.o \
	configparser.o \
	connections.o \
	connections-glue.o \
	crc32.o \
	data_array.o \
	data_config.o \
	data_count.o \
	data_fastcgi.o \
	data_integer.o \
	data_string.o \
	etag.o \
	fdevent.o \
	fdevent_freebsd_kqueue.o \
	fdevent_libev.o \
	fdevent_linux_sysepoll.o \
	fdevent_poll.o \
	fdevent_select.o \
	fdevent_solaris_devpoll.o \
	fdevent_solaris_port.o \
	http_chunk.o \
	http-header-glue.o \
	inet_ntop_cache.o \
	joblist.o \
	keyvalue.o \
	log.o \
	network.o \
	network_freebsd_sendfile.o \
	network_linux_sendfile.o \
	network_openssl.o \
	network_solaris_sendfilev.o \
	network_write.o \
	network_writev.o \
	plugin.o \
	proc_open.o \
	request.o \
	response.o \
	server.o \
	splaytree.o \
	stat_cache.o \
	status_counter.o \
	stream.o \
	md5.o

mod_objs :=	mod_access.o \
	mod_accesslog.o \
	mod_alias.o \
	mod_cgi.o \
	mod_cml.o \
	mod_cml_funcs.o \
	mod_cml_lua.o \
	mod_compress.o \
	mod_dirlisting.o \
	mod_evasive.o \
	mod_evhost.o \
	mod_expire.o \
	mod_extforward.o \
	mod_fastcgi.o \
	mod_flv_streaming.o \
	mod_indexfile.o \
	mod_magnet.o \
	mod_magnet_cache.o \
	mod_mysql_vhost.o \
	mod_proxy.o \
	mod_redirect.o \
	mod_rewrite.o \
	mod_rrdtool.o \
	mod_scgi.o \
	mod_secure_download.o \
	mod_setenv.o \
	mod_simple_vhost.o \
	mod_skeleton.o \
	mod_ssi.o \
	mod_ssi_expr.o \
	mod_ssi_exprparser.o \
	mod_staticfile.o \
	mod_status.o \
	mod_trigger_b4_dl.o \
	mod_userdir.o \
	mod_usertrack.o \
	mod_webdav.o 

mod_so := $(mod_objs:.o=.so)

all: http_auth.o mod_auth.o mod_auth.so lighttpd-angel.o $(objs) $(mod_objs) $(mod_so) lighttpd lighttpd-angel proc_open

$(objs): %.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@
	
$(mod_objs): %.o: %.c
	$(CC) -c $(CFLAGS) -fPIC -DPIC $< -o $@
mod_auth.o: %.o: %.c
	$(CC) -c $(CFLAGS) -fPIC -DPIC -lm $< -o $@
$(mod_so): %.so:%.o
	gcc -shared  -fPIC -DPIC -g -O2 -Wl,-soname -Wl,$@ $^ -o $@
http_auth.o: %.o: %.c
	$(CC) -c $(CFLAGS) -fPIC -DPIC $< -o $@
	
mod_auth.so: %.so:%.o
	gcc -shared  -fPIC -DPIC -g -O2 -Wl,-soname -Wl,$@ -lcrypt -lm $^ http_auth.o -o $@
	
lighttpd-angel.o: %.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@	
	
lighttpd-angel:	lighttpd-angel.o
	gcc  -g -O2 -Wall -W -Wshadow -pedantic -std=gnu99   -o lighttpd-angel lighttpd-angel.o
	
lighttpd: $(objs)
	gcc  -g -O2 -Wall -W -Wshadow -pedantic -std=gnu99 -export-dynamic  -o lighttpd $(objs) -ldl
	
proc_open-proc_open.o:
	gcc -DDEBUG_PROC_OPEN $(CFLAGS) -MT proc_open-proc_open.o -c -o proc_open-proc_open.o `test -f 'proc_open.c' || echo './'`proc_open.c
	
proc_open-buffer.o:	
	gcc -DDEBUG_PROC_OPEN $(CFLAGS) -MT proc_open-buffer.o -c -o proc_open-buffer.o `test -f 'buffer.c' || echo './'`buffer.c
proc_open: proc_open-buffer.o proc_open-proc_open.o
	gcc -g -O2 -Wall -W -Wshadow -pedantic -std=gnu99 -o proc_open proc_open-proc_open.o proc_open-buffer.o 
