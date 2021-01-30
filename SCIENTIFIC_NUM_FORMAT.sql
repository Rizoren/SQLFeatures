/*
  Copyright (c) 2021 Vladimir Butygin.
  This work is licensed under the terms of the Apache License, Version 2.0.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  
  Release for Firebird 3!

  Converts a number with a large order to 2 values: mantissa and order.

  Params:
    ID_VAL  - id for link result;
    VAL     - value for conversion;
    LIM     - order limit.

  Returned row:
    ID      - id for link;
    MANT    - mantissa;
    ORD     - order.

  Example:
    tabel myData (id bigint, rawnum double precision) // row: 1, 253.5975E-56

  select d.id, d.rawnum, t1.mant, t1.ord, t2.mant, t2.ord 
  from myData d
  left join SCIENTIFIC_NUM_FORMAT(d.id, d.rawnum) t1 on t1.id = d.id
  left join SCIENTIFIC_NUM_FORMAT(d.id, d.rawnum, 50) t2 on t2.id = d.id

  Result:
  d.id  | d.rawnum      | t1.mant       | t1.ord  | t2.mant       | t2.ord
  1     | 253.5975E-56  | 2,5359750000  | -54     | 0,0002535975  | -50

*/

create or alter procedure SCIENTIFIC_NUM_FORMAT (
    ID_VAL bigint,
    VAL double precision,
    LIM integer = -1)
returns (
    ID bigint,
    MANT numeric(18,10),
    ORD integer)
as
begin
  ID = :id_val;
  with recursive scientific_f(mant_s, mant, ord_s, ord) as (
    select iif(:val < 0,-1,1) mant_s, abs(:val) as mant, iif(abs(:val) < 1,-1,1) ord_s, 0 as ord from rdb$database
    union all
    select mant_s, iif(ord_s = 1,mant / 10, mant * 10), ord_s, ord + 1 from scientific_f
    where ((ord_s = 1 and mant / 10 > 1) or (ord_s = -1 and mant * 10 < 10))
  )
  select first 1 mant_s*mant, ord_s*ord from scientific_f
  where ((:lim >= 0 and ord <= :lim) or (:lim < 0)) order by ord desc
  into :mant, :ord;
  suspend;
end
