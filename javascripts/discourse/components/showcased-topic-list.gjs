import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import BasicTopicList from "discourse/components/basic-topic-list";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import { getCategoryAndTagUrl } from "discourse/lib/url";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";

export default class ShowcasedTopicList extends Component {
  @service store;
  @service composer;
  @service currentUser;
  @service router;

  @tracked isLoading = true;
  @tracked topicList;
  @tracked resolvedTags = [];
  tagNames = this.args.tags.length > 0 ? this.args.tags : "";
  category = this.args.category;

  get moreHref() {
    const tagNames = this.tagNames;
    const encodedTags = tagNames ? tagNames.join("%2C") : "";
    const tag = this.resolvedTags[0];

    if (this.category && !tagNames) {
      return `${this.category.url}/l/${settings.filter}`;
    } else if (!this.category && tagNames) {
      if (tagNames.length > 1) {
        return `/search?expanded=true&q=tags%3A${encodedTags}`;
      }
      if (!tag) {
        return "";
      }
      return `${getCategoryAndTagUrl(null, null, tag)}/l/${settings.filter}`;
    } else if (this.category && tagNames) {
      if (tagNames.length === 1) {
        if (!tag) {
          return "";
        }
        return `${getCategoryAndTagUrl(this.category, true, tag)}/l/${settings.filter}`;
      }
      return `/search?expanded=true&q=%23${this.category.slug} tags%3A${encodedTags}`;
    } else {
      return "";
    }
  }

  @action
  async getTopics() {
    if (!this.category && !this.tagNames) {
      return;
    }

    const filter = {
      filter: settings.filter,
      params: {
        category: this.category?.id,
        tags: this.tagNames,
      },
    };

    try {
      if (this.tagNames?.length > 0) {
        const listTags = await this.store.findAll("listTag", {
          only_tags: this.tagNames.join(","),
        });
        this.resolvedTags = (listTags.content || []).map((t) =>
          this.store.createRecord("tag", t)
        );
      }

      const topicList = await this.store.findFiltered("topicList", filter);
      this.topicList = topicList.topics.slice(0, settings.max_list_length);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error getting topics:", error);
    } finally {
      this.isLoading = false;
    }
  }

  @action
  createTopic() {
    if (this.currentUser) {
      this.composer.open({
        action: Composer.CREATE_TOPIC,
        draftKey: Composer.NEW_TOPIC_KEY,
        categoryId: this.category?.id,
        tags: this.tagNames,
      });
    } else {
      this.router.transitionTo("login");
    }
  }

  <template>
    <div class="header-wrapper" {{didInsert this.getTopics}}>
      <a href={{this.moreHref}}><h2>{{@title}}</h2></a>
      <DButton
        @action={{this.createTopic}}
        @translatedLabel={{i18n (themePrefix "showcased_categories.new_post")}}
        class="btn-primary btn"
      />
    </div>

    <ConditionalLoadingSpinner @condition={{this.isLoading}}>
      <BasicTopicList @topics={{this.topicList}} @showPosters="false" />
    </ConditionalLoadingSpinner>

    <a href={{this.moreHref}} class="btn btn-default btn-more">
      {{i18n (themePrefix "showcased_categories.view_more")}}
    </a>
  </template>
}
