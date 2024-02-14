import { apiInitializer } from "discourse/lib/api";
import TwoTopicList from "../components/two-topic-list";

export default apiInitializer("1.14.0", (api) => {
  let outlet = settings.plugin_outlet;

  if (settings.show_as_sidebar) {
    outlet = "before-topic-list";
  }

  api.renderInOutlet(outlet, TwoTopicList);
});
