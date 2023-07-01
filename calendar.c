#include <templatizer.h>
#include <libical/ical.h>
#include <string.h>

int save()
{
	icalcomponent *event;
	icalproperty *prop;
	icalparameter *param;
	struct icaltimetype atime;

	/* create new VEVENT component */
	event = icalcomponent_new(ICAL_VEVENT_COMPONENT);

	/* add DTSTAMP property to the event */
	prop = icalproperty_new_dtstamp(atime);
	icalcomponent_add_property(event, prop);

	/* add UID property to the event */
	prop = icalproperty_new_uid("guid-1.example.com");
	icalcomponent_add_property(event, prop);

	/* add ORGANIZER (with ROLE=CHAIR) to the event */
	prop = icalproperty_new_organizer("mrbig@example.com");
	param = icalparameter_new_role(ICAL_ROLE_CHAIR);
	icalproperty_add_parameter(prop, param);
	icalcomponent_add_property(event, prop);

	return 0;
}

static int init(tmpl_ctx_t data, tmpl_cb_t cb)
{
	const char *method;
	int result;

	method = getenv("REQUEST_METHOD");
	if (method == NULL) {
		return 1;
	}
	if (strcmp(method, "POST") == 0) {
		result = save();
		if (result != 0) {
			return 1;
		}
	}

	cb->set_output_format(data, TMPL_FMT_HTML);
	cb->send_default_headers(data);
	puts("<!DOCTYPE html>");
	return 0;
}

static void quit() {}

struct pollen_plugin templatizer_plugin_v1 = {
	&init,
	&quit
};

