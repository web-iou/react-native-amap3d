import { PureComponent } from "react";

export default class Component<P, S = {}> extends PureComponent<P, S> {
  mounted = false;

  componentDidMount() {
    this.mounted = true;
  }

  componentWillUnmount() {
    this.mounted = false;
  }
}
