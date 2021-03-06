import React from 'react';
import { sprintf } from 'foremanReact/common/I18n';
import { Table, FormControl, FormGroup, HelpBlock, Spinner } from 'patternfly-react';
import { validateQuantity } from '../../SubscriptionValidations';
import { KEY_CODES } from '../../../../move_to_foreman/common/helpers';

export const entitlementsInlineEditFormatter =
  inlineEditController => Table.inlineEditFormatterFactory({
    isEditing: additionalData =>
      inlineEditController.isEditing(additionalData),
    renderValue: (value, additionalData) => {
      const { rowData } = additionalData;
      if (rowData.available < 0 || !rowData.upstream_pool_id) {
        return (
          <td>{rowData.available < 0 ? __('Unlimited') : rowData.available}</td>
        );
      }
      return (
        <td className="editable">
          <div
            onClick={() => inlineEditController.onActivate(additionalData)}
            onKeyPress={(e) => {
              if (e.keyCode === KEY_CODES.ENTER_KEY) {
                inlineEditController.onActivate(additionalData);
              }
            }}
            className="input"
            role="textbox"
            tabIndex={0}
          >
            {value}
          </div>
        </td>
      );
    },
    renderEdit: (value, additionalData) => {
      const {
        upstreamAvailable, upstreamAvailableLoaded, maxQuantity,
      } = additionalData.rowData;

      const className = inlineEditController.hasChanged(additionalData)
        ? 'editable editing changed'
        : 'editable editing';

      let maxMessage;
      if (maxQuantity && upstreamAvailableLoaded && (upstreamAvailable !== undefined)) {
        maxMessage = (upstreamAvailable < 0)
          ? __('Unlimited')
          : sprintf(__('Max %(maxQuantity)s'), { maxQuantity });
      }

      const validation = validateQuantity(value, maxQuantity);

      const formGroup = (
        // We have to block editing until available quantities are loaded.
        // Otherwise changes that user typed prior to update would be deleted,
        // because we save them onBlur. Unfortunately onChange can't be used
        // because reactabular always creates new component instances
        // in re-render.
        // The same issue prevents from correct switching inputs on TAB.
        // See the reactabular code for details:
        // https://github.com/reactabular/reactabular/blob/master/packages/reactabular-table/src/body-row.js#L58
        <Spinner loading={!upstreamAvailableLoaded} size="xs">
          <FormGroup
            validationState={validation.state}
          >
            <FormControl
              type="text"
              defaultValue={value}
              onBlur={e =>
                inlineEditController.onChange(e.target.value, additionalData)
              }
            />
            <HelpBlock>
              {maxMessage}
              <div className="validationMessages">
                {validation.message}
              </div>
            </HelpBlock>
          </FormGroup>
        </Spinner>
      );

      return (
        <td className={className}>
          {formGroup}
        </td>
      );
    },
  });

export default entitlementsInlineEditFormatter;
