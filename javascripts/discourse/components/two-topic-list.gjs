import Component from "@glimmer/component";
import { service } from "@ember/service";
import PluginOutlet from "discourse/components/plugin-outlet";
import bodyClass from "discourse/helpers/body-class";
import { defaultHomepage } from "discourse/lib/utilities";
import Category from "discourse/models/category";
import ShowcasedTopicList from "../components/showcased-topic-list";

export default class TwoTopicList extends Component {
  @service router;

  get category1() {
    return Category.findById(settings.feed_one_category);
  }

  get category2() {
    return Category.findById(settings.feed_two_category);
  }

  get tags1() {
    return settings.feed_one_tag.split("|").filter((tag) => tag.trim() !== "");
  }

  get tags2() {
    return settings.feed_two_tag.split("|").filter((tag) => tag.trim() !== "");
  }

  get showTopicLists() {
    return (
      (this.category1 || this.tags1.length > 0) &&
      (this.category2 || this.tags2.length > 0)
    );
  }

  get shouldShow() {
    if (!this.showTopicLists) {
      return false;
    } else {
      let showSidebar =
        settings.show_as_sidebar &&
        this.router.currentRouteName === "discovery.latest";
      return (
        this.router.currentRouteName === `discovery.${defaultHomepage()}` ||
        showSidebar
      );
    }
  }

  <template>
    {{#if this.shouldShow}}
      {{#if settings.show_as_sidebar}}
        {{bodyClass "showcased-categories-sidebar"}}
      {{/if}}
      <PluginOutlet
        @name="above-discourse-showcased-categories"
        @connectorTagName="div"
      />
      <div class="wrap custom-homepage-columns">
        <div class="col col-1">
          <ShowcasedTopicList
            @category={{this.category1}}
            @tags={{this.tags1}}
            @title={{settings.feed_one_title}}
          />
        </div>
        <div class="col col-2">
          <ShowcasedTopicList
            @category={{this.category2}}
            @tags={{this.tags2}}
            @title={{settings.feed_two_title}}
          />
        </div>
      </div>
    {{/if}}
  </template>
}
