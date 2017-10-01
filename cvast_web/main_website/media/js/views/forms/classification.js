define(['jquery', 
    'underscore', 
    'knockout',
    'views/forms/wizard-base', 
    'views/forms/sections/branch-list',
    'bootstrap-datetimepicker',
    'summernote'], function ($, _, ko, WizardBase, BranchList, datetimepicker, summernote) {

    return WizardBase.extend({
        initialize: function() {
            WizardBase.prototype.initialize.apply(this);

            var self = this;
            var date_picker = $('.datetimepicker').datetimepicker({
                pickTime: false, 
                dateFormat: 'yy-mm-dd'
            });            
            var currentEditedClassification = this.getBlankFormData();

            date_picker.on('dp.change', function(evt){
                $(this).find('input').trigger('change'); 
            });

            this.editClassification = function(branchlist){
                self.switchBranchForEdit(branchlist);
            }

            this.deleteClassification = function(branchlist){
                self.deleteClicked(branchlist);
            }

            ko.applyBindings(this, this.$el.find('#existing-classifications')[0]);

            this.addBranchList(new BranchList({
                data: currentEditedClassification,
                dataKey: 'PHASE_TYPE_ASSIGNMENT.E17'
            }));
            this.addBranchList(new BranchList({
                el: this.$el.find('#resource-type-section')[0],
                data: currentEditedClassification,
                dataKey: 'HERITAGE_RESOURCE_TYPE.E55',
                singleEdit: true
            }));
            this.addBranchList(new BranchList({
                el: this.$el.find('#resource-use-section')[0],
                data: currentEditedClassification,
                dataKey: 'HERITAGE_RESOURCE_USE_TYPE.E55',
                singleEdit: true
            }));
            this.addBranchList(new BranchList({
                el: this.$el.find('#related-features-section')[0],
                data: currentEditedClassification,
                dataKey: 'ANCILLARY_FEATURE_TYPE.E55',
                validateBranch: function (nodes) {
                    return this.validateHasValues(nodes);
                }
            }));
            this.addBranchList(new BranchList({
                el: this.$el.find('#period-section')[0],
                data: currentEditedClassification,
                dataKey: 'CULTURAL_PERIOD.E55',
                singleEdit: true
            }));            
            this.addBranchList(new BranchList({
                el: this.$el.find('#style-section')[0],
                data: currentEditedClassification,
                dataKey: 'STYLE.E55',
                validateBranch: function (nodes) {
                    return this.validateHasValues(nodes);
                }
            }));     
            this.addBranchList(new BranchList({
                el: this.$el.find('#to-date-section')[0],
                data: currentEditedClassification,
                dataKey: 'TO_DATE.E49',
                singleEdit: true
            }));
            this.addBranchList(new BranchList({
                el: this.$el.find('#from-date-section')[0],
                data: currentEditedClassification,
                dataKey: 'FROM_DATE.E49',
                singleEdit: true
            }));

        },

        startWorkflow: function() { 
            this.switchBranchForEdit(this.getBlankFormData());
        },

        switchBranchForEdit: function(classificationData){
            this.prepareData(classificationData);

            _.each(this.branchLists, function(branchlist){
                branchlist.data = classificationData;
                branchlist.undoAllEdits();
            }, this);

            this.toggleEditor();
        },

        prepareData: function(assessmentNode){
            _.each(assessmentNode, function(value, key, list){
                assessmentNode[key].domains = this.data.domains;
            }, this);
            return assessmentNode;
        },

        getBlankFormData: function(){
            return this.prepareData({
                'HERITAGE_RESOURCE_TYPE.E55': {
                    'branch_lists':[]
                },
                'HERITAGE_RESOURCE_USE_TYPE.E55': {
                    'branch_lists':[]
                },
                'ANCILLARY_FEATURE_TYPE.E55': {
                    'branch_lists':[]
                },
                'CULTURAL_PERIOD.E55': {
                    'branch_lists':[]
                },   
                'FROM_DATE.E49': {
                    'branch_lists': []
                },
                'TO_DATE.E49': {
                    'branch_lists': []
                },        
                'STYLE.E55': {
                    'branch_lists':[]
                },
                'PHASE_TYPE_ASSIGNMENT.E17': {
                    'branch_lists':[]
                }
            })
        },

        deleteClicked: function(branchlist) {

            this.deleted_assessment = branchlist;
            this.confirm_delete_modal = this.$el.find('.confirm-delete-modal');
            this.confirm_delete_modal_yes = this.confirm_delete_modal.find('.confirm-delete-yes');
            this.confirm_delete_modal_yes.removeAttr('disabled');
            
            var warningtextElement = this.confirm_delete_modal.find('.modal-body [name="warning-text-body"]');
            // Set warning text based on which field was filled 
            var confirmMessageItem = ''
            if (branchlist['HERITAGE_RESOURCE_TYPE.E55'].branch_lists[0] !== undefined) {
                confirmMessageItem = branchlist['HERITAGE_RESOURCE_TYPE.E55'].branch_lists[0].nodes[0].label;
            }
            else if (branchlist['CULTURAL_PERIOD.E55'].branch_lists[0] !== undefined) {
                confirmMessageItem = branchlist['CULTURAL_PERIOD.E55'].branch_lists[0].nodes[0].label;
            }
            warningtextElement.text(confirmMessageItem);
            this.confirm_delete_modal.modal('show');
        }

    });
});