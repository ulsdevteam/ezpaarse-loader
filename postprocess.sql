BEGIN

INSERT INTO EZPAARSE_RESULT_DEPTS
SELECT
	ez."recordid",
	stu.rc_cd,
	stu.department_cd
FROM
	UDA4ULA.EZPAARSE_RESULTS ez 
	INNER JOIN
	(
		SELECT DISTINCT
			st.username,
			cal.full_dt + interval '1' day - interval '1' second end_dt,
			add_months(cal.full_dt, -1) + interval '1' day AS start_dt,
			CASE WHEN dp.responsibility_center_cd = '00' THEN rc.responsibility_center_cd ELSE dp.responsibility_center_cd END as rc_cd,
			CASE WHEN dp.responsibility_center_cd = '00' THEN rc.responsibility_center_descr ELSE dp.responsibility_center_descr END as rc_descr,
			dp.department_cd,
			dp.department_descr,
			cal.full_dt
		FROM
			UD_DATA.ST_ENROLLMENT en
			INNER JOIN UD_DATA.ud_calendar cal ON cal.calendar_key = en.calendar_key
			INNER JOIN UD_DATA.ud_term t ON t.term_key = en.term_key
			INNER JOIN UD_DATA.ud_student st ON st.student_key = en.student_key
			INNER JOIN UD_DATA.ud_academic_plan_subplan ap ON en.academic_plan_subplan_key = ap.academic_plan_subplan_key
			INNER JOIN UD_DATA.ud_major_department md ON md.academic_plan_subplan_key = ap.academic_plan_subplan_key
			INNER JOIN UD_DATA.ud_department dp ON dp.department_cd= md.department_cd
			INNER JOIN UD_DATA.ud_responsibility_center rc ON rc.responsibility_center_cd = ap.responsibility_center_cd
		WHERE
			dp.current_flg = 1
			AND rc.current_flg = 1
			AND cal.st_monthly_retain_flg = 'Y'
			AND cal.full_dt > '01-JAN-19'
		ORDER BY
			cal.full_dt
	) stu ON ez."login" = stu.username AND (EZ."datetime" BETWEEN stu.start_dt AND stu.end_dt)
WHERE
	ez."recordid" NOT IN (SELECT "recordid" FROM UDA4ULA.EZPAARSE_RESULT_DEPTS)
	AND ez."datetime" < TRUNC(SYSDATE, 'MM')
UNION
SELECT
	ez."recordid",
	em.rc_cd,
	em.department_cd
FROM
	UDA4ULA.EZPAARSE_RESULTS ez 
	INNER JOIN
	(
		SELECT DISTINCT
			em.username,
			cal.full_dt + interval '1' day - interval '1' second end_dt,
			add_months(cal.full_dt, -1) + interval '1' day AS start_dt,
			dep.responsibility_center_cd as rc_cd,
			dep.responsibility_center_descr as rc_descr,
			dep.department_cd,
			dep.department_descr
		FROM
			ud_data.py_employment py
			INNER JOIN ud_data.ud_calendar cal ON cal.calendar_key = py.calendar_key
			INNER JOIN UD_DATA.ud_employee em ON py.employee_key = em.employee_key 
			INNER JOIN UD_DATA.ud_department dep ON dep.department_cd = em.department_cd
			INNER JOIN ud_data.ud_job jb ON py.job_key = jb.job_key
		WHERE
			dep.current_flg = 1
			AND cal.py_month_end_flg = 'Y' 
			AND job_type != 'Student'
			AND cal.full_dt > '01-JAN-19' 
		ORDER BY
			start_dt
	) em ON ez."login" = em.username AND (EZ."datetime" BETWEEN em.start_dt AND em.end_dt)
WHERE
	ez."recordid" NOT IN (SELECT "recordid" FROM UDA4ULA.EZPAARSE_RESULT_DEPTS)
	AND ez."datetime" < TRUNC(SYSDATE, 'MM')
;

INSERT INTO
  EZPAARSE_RESULT_DEPTS
SELECT
  "recordid",
  "rc",
  '00000'
FROM
  EZPAARSE_RESULTS
  JOIN EZPAARSE_SPACCT_RCS ON (EZPAARSE_RESULTS."login" = EZPAARSE_SPACCT_RCS."login")
WHERE
  "recordid" NOT IN (SELECT "recordid" FROM EZPAARSE_RESULT_DEPTS)
  AND EZPAARSE_RESULTS."datetime" < TRUNC(SYSDATE, 'MM')
;

UPDATE EZPAARSE_RESULTS SET "user_hash" = (SELECT STANDARD_HASH(S."salt"||EZPAARSE_RESULTS."login") FROM EZPAARSE_SALT S) WHERE "user_hash" IS NULL;

COMMIT;
EXCEPTION WHEN OTHERS THEN
ROLLBACK;
RAISE;
END;
/
EXIT
