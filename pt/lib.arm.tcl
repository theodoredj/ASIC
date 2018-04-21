lappend link_library /proj/elnath1t/wa/elnath1t/release/current/CORTEXM0PLUS_$LIB.db
lappend link_library /proj/elnath1t/wa/elnath1t/release/current/CORTEXM3INTEGRATION_$LIB.db
lappend link_library /proj/elnath1t/wa/elnath1t/release/current/CORTEXR5_$LIB.db
lappend link_library /proj/elnath1t/wa/elnath1t/release/current/Vic_$LIB.db
foreach iLIB [ls /proj/elnath1/release/DE/2.0/LEC/*.db] {lappend link_library $iLIB}
