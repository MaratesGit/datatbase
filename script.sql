

ALTER TABLE otdr ADD COLUMN otdr_active_channel integer;
ALTER TABLE reference_trace ADD COLUMN range integer;
ALTER TABLE reference_trace ADD COLUMN average_time integer;
ALTER TABLE fiber ADD COLUMN channel integer;
CREATE INDEX ind_dots_id_trace  ON dots  USING btree  (id_trace);
CREATE INDEX ind_alfa_compare_id_trace  ON alfa_compare  USING btree   (id_trace);
CREATE INDEX ind_segments_alfas_id_fiber_segments   ON segments_alfas   USING btree   (id_fiber_segments)
CREATE INDEX ind_reference_point_id_trace  ON reference_point USING btree  (id_trace);

ALTER TABLE alarm
  ADD CONSTRAINT fk_alarm_reference_trace FOREIGN KEY (id_trace)
      REFERENCES trace (id_trace) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE alfa_compare
  ADD CONSTRAINT fk_alfa_compare_reference_trace FOREIGN KEY (id_trace)
      REFERENCES trace (id_trace) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;

alter table fiber rename column id_fiber_group to Segments_Max;
Drop table fiber_group CASCADE;


alter table segments_alfas add column id_fiber;
Alter table segments_alfas add foreign key (id_fiber) REFERENCES  fiber;
alter table trace rename column length to range;

alter table trace rename column accumvalue to average_time;
alter table reference_trace drop column accumvalue;
alter table reference_trace drop column length;
alter table reference_trace add column appr_point integer;

alter table fiber_segments add column sigma integer;
alter table fiber drop column aproximation_points;


alter table fiber drop column gi;
alter table reference_trace add column gi double precision;
alter table referance_trace rename column id_reference_point to id;

