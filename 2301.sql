alter table otdr add constraint otdr_imei_unique UNIQUE (otdr_imei);
alter table otdr drop column otdr_cert;
