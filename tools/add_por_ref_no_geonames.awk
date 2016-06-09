##
# That AWK script adds the list of non Geonames POR (points of reference)
# appearing in the reference data. The input files are:
#  * Re-formatted list of POR: optd_por_public.csv.wonoiata (temporary)
#  * Non-Geonames referential data:   optd_por_no_geonames.csv
#  * Deprecated POR still referenced: optd_por_ref_exceptions.csv
#
# See also the make_optd_por_public.awk AWK script for details on the format.
#
# Sample output lines:
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|^488^Ukraine
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s^427^France
# UNS^ZZZZ^^Y^8298981^1^Umnak Island Airport^Umnak Island Airport^53.38277^-167.88946^S^AIRP^^^1948-01-01^Air base closed after WWII, in 1947^US^^United States^North America^^^^^^^^^^^^America/USA^^^^-1^UMB^Umnak Island^UMB|5877180|Umnak Island|Umnak Island^^AK^A^http://en.wikipedia.org/wiki/Cape_Field_at_Fort_Glenn^^1^Alaska
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "add_por_ref_no_geonames.awk"

	# List of POR known to be still valid in
	# the reference data, but no longer valid
	# in OPTD
	delete optd_por_ref_dpctd_list
	optd_por_ref_dpctd_list_file = "optd_por_ref_exceptions.csv"

    #
	today_date = mktime ("YYYY-MM-DD")
}

##
# File of deprecated, but still referenced, POR
#
# Sample lines:
# por_code^source^env_id^date_from^date_to^comment
# AIY^R^^^^AIY used to be Atlantic City, New Jersey (NJ), USA, Geonames ID: 4500546
/^[A-Z]{3}\^R\^\^\^\^[^^]*$/ {
    # IATA code
    iata_code = $1

	# Register the fact that that POR is deprecated but still referenced
	optd_por_ref_dpctd_list[iata_code] = 1
}

##
# List of:
# * Re-formatted list of POR: optd_por_public.csv.wonoiata (temporary)
# * Non-Geonames referential data:   optd_por_no_geonames.csv
# Those files have the exact same format as the output of optd_por_public.csv
#
# Sample input lines:
# UNS^ZZZZ^^Y^8298981^1^Umnak Island Airport^Umnak Island Airport^53.38277^-167.88946^S^AIRP^^^1948-01-01^Air base closed after WWII, in 1947^US^^United States^North America^^^^^^^^^^^^America/USA^^^^-1^UMB^Umnak Island^UMB|5877180|Umnak Island|Umnak Island^^AK^A^http://en.wikipedia.org/wiki/Cape_Field_at_Fort_Glenn^^1^Alska
#
/^[A-Z]{3}\^([A-Z]{4}|)\^([0-9A-Z]{3,4}|)\^(Y|N)\^[0-9]{1,10}\^([0-9]{1,10}|)\^/ {

	if (NF == 46) {
		# IATA code
		iata_code = $1

		# Check that the POR is not known to be an exception
		if (!(iata_code in optd_por_ref_dpctd_list)) {
			print ($0)
		} else {
			delete optd_por_ref_dpctd_list[iata_code]
		}

	} else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
	}
}


END {
	for (iata_code in optd_por_ref_dpctd_list) {
		print ("[" awk_file "] !!!! Warning: " iata_code \
				" is still referenced in the '" \
				optd_por_ref_dpctd_list_file "' file, " \
				"but has disappeared from reference data. ") > error_stream
	}
}
