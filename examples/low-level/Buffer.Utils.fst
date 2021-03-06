module Buffer.Utils

open FStar.Mul
open FStar.Ghost
open FStar.HyperStack
open FStar.HST
open FStar.Int.Cast
open FStar.UInt8
open FStar.UInt32
open FStar.Buffer

let u32 = UInt32.t
let u8 = UInt8.t
let uint32s = buffer u32
let bytes = buffer u8

// TODO: Needs to be instanciated differently
assume MaxUint8: FStar.UInt.max_int 8 = 255
assume MaxUint32: FStar.UInt.max_int 32 = 4294967295

(* Rotate operators on UInt32.t *)
let op_Greater_Greater_Greater (a:u32) (s:u32{v s <= 32}) =
  let (m:u32{v m = 32}) = 32ul in
  (op_Greater_Greater_Hat a s) |^ (a <<^ (m -^ s))
let op_Less_Less_Less (a:u32) (s:u32{v s <= 32}) =
  let (m:u32{v m = 32}) = 32ul in  
  (op_Less_Less_Hat a s) |^ (op_Greater_Greater_Hat a (m -^ s))

val xor_bytes_inplace: output:bytes -> in1:bytes{disjoint in1 output} -> 
  len:u32{v len <= length output /\ v len <= length in1} -> STL unit
  (requires (fun h -> live h output /\ live h in1))
  (ensures  (fun h0 _ h1 -> live h0 output /\ live h0 in1 /\ live h1 output /\ live h1 in1
    /\ modifies_1 output h0 h1 ))
let rec xor_bytes_inplace output in1 len =
  if len =^ 0ul then ()
  else
    begin
      let i    = len -^ 1ul in
      let in1i = index in1 i in
      let oi   = index output i in
      let oi   = UInt8.logxor in1i oi in
      upd output i oi;
      xor_bytes_inplace output in1 i
    end

(* Read an unsigned int32 out of 4 bytes *)
val uint32_of_bytes: b:bytes{length b >= 4} -> STL u32
  (requires (fun h -> live h b))
  (ensures (fun h0 r h1 -> h0 == h1 /\ live h0 b))
let uint32_of_bytes (b:bytes{length b >= 4}) =
  let b0 = (index b 0ul) in
  let b1 = (index b 1ul) in
  let b2 = (index b 2ul) in
  let b3 = (index b 3ul) in
  let r = (op_Less_Less_Hat (uint8_to_uint32 b3) 24ul)
	+%^ (op_Less_Less_Hat (uint8_to_uint32 b2) 16ul)
	+%^ (op_Less_Less_Hat (uint8_to_uint32 b1) 8ul)
	+%^ uint8_to_uint32 b0 in
  r

(* Stores the content of a byte buffer into a unsigned int32 buffer *)
val bytes_of_uint32s: output:bytes -> m:uint32s{disjoint output m} -> len:u32{v len <=length output /\ v len<=op_Multiply 4 (length m)} -> STL unit
  (requires (fun h -> live h output /\ live h m))
  (ensures (fun h0 _ h1 -> live h0 output /\ live h0 m /\ live h1 output /\ live h1 m
    /\ modifies_1 output h0 h1 ))
let rec bytes_of_uint32s output m l =
  if l >^ 0ul then
    begin
    let rem = l %^ 4ul in
    if UInt32.gt rem 0ul then
      begin
      let l = l -^ rem in
      let x = index m (l /^ 4ul) in
      let b0 = uint32_to_uint8 (x &^ 255ul) in
      upd output l b0;
      if UInt32.gt rem 1ul then
        begin
        let b1 = uint32_to_uint8 ((x >>^ 8ul) &^ 255ul) in
        upd output (l +^ 1ul) b1;
	if UInt32.gt rem 2ul then
	  begin
	  let b2 = uint32_to_uint8 ((x >>^ 16ul) &^ 255ul) in
	  upd output (l +^ 2ul) b2
          end
	else ()
	end
      else ();
      bytes_of_uint32s output m l
      end
    else
      begin
      let l = l -^ 4ul in
      let x = index m (l /^ 4ul) in
      let b0 = uint32_to_uint8 (x &^ 255ul) in
      let b1 = uint32_to_uint8 ((x >>^ 8ul) &^ 255ul) in
      let b2 = uint32_to_uint8 ((x >>^ 16ul) &^ 255ul) in
      let b3 = uint32_to_uint8 ((x >>^ 24ul) &^ 255ul) in
      upd output l b0;
      upd output (l +^ 1ul) b1;
      upd output (l +^ 2ul) b2;
      upd output (l +^ 3ul) b3;
      bytes_of_uint32s output m l
      end
    end

(* Stores the content of a byte buffer into a unsigned int32 buffer *)
val bytes_of_uint32: output:bytes{length output >= 4} -> m:u32 -> STL unit
  (requires (fun h -> live h output))
  (ensures (fun h0 _ h1 -> live h1 output
    /\ modifies_1 output h0 h1 ))
let rec bytes_of_uint32 output x =
  let b0 = uint32_to_uint8 (x &^ 255ul) in
  let b1 = uint32_to_uint8 ((x >>^ 8ul) &^ 255ul) in
  let b2 = uint32_to_uint8 ((x >>^ 16ul) &^ 255ul) in
  let b3 = uint32_to_uint8 ((x >>^ 24ul) &^ 255ul) in
  upd output 0ul b0;
  upd output 1ul b1;
  upd output 2ul b2;
  upd output 3ul b3

(* A form of memset, could go into some "Utils" functions module *)
val memset: b:bytes -> z:u8 -> len:u32 -> STL unit
  (requires (fun h -> live h b /\ v len <= length b))
  (ensures  (fun h0 _ h1 -> modifies_1 b h0 h1 /\ live h1 b
    (* /\ Seq.slice (as_seq h1 b) 0 (v len) == Seq.create (v len) z *)
    (* /\ Seq.slice (as_seq h1 b) (v len) (length b) == (as_seq h0 b) (v len) (length b) *)
    ))
let rec memset b z len =
  if len =^ 0ul then ()
  else (
    let i = len -^ 1ul in
    upd b i z;
    memset b z i
  )
