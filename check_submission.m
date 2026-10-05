function ok = check_submission(path)
% ASEN 6337 - EuroSAT competition - check your submission file BEFORE uploading it.
%
%     check_submission('submission.csv')
%
% Checks the file the same way the scorer does (right columns, every test id
% exactly once, class names spelled exactly), using sample_submission.csv as the
% list of test ids. It cannot tell you your score: it only tells you whether the
% file will be ACCEPTED. Base MATLAB only.

classes = ["AnnualCrop","Forest","HerbaceousVegetation","Highway","Industrial", ...
           "Pasture","PermanentCrop","Residential","River","SeaLake"];
opts = {'TextType','string','Delimiter',',','VariableNamingRule','preserve'};

tmpl = readtable('sample_submission.csv', opts{:});
sub  = readtable(path, opts{:});
names = strtrim(string(sub.Properties.VariableNames));
if ~all(ismember(["id","label"], names))
    error('REJECTED: the first line must be exactly  id,label  (found: %s)', strjoin(names, ','));
end

ids    = strtrim(string(sub.id));
labels = strtrim(string(sub.label));
test_ids = strtrim(string(tmpl.id));

problems = strings(0);
[u, ~, k] = unique(ids);
dup = u(accumarray(k, 1) > 1);
if ~isempty(dup),     problems(end+1) = sprintf('%d ids appear more than once, e.g. %s', numel(dup), dup(1)); end
missing = setdiff(test_ids, ids);
if ~isempty(missing), problems(end+1) = sprintf('%d test ids have no prediction, e.g. %s', numel(missing), missing(1)); end
extra = setdiff(ids, test_ids);
if ~isempty(extra),   problems(end+1) = sprintf('%d ids are not test ids, e.g. %s', numel(extra), extra(1)); end
bad = setdiff(unique(labels), classes);
if ~isempty(bad)
    problems(end+1) = "unknown class names: " + strjoin(bad(1:min(5,end)), ', ');
    if any(~isnan(double(bad)))
        problems(end+1) = "hint: labels are numbers; write classes(p), the class NAME, not the index p";
    end
end

fprintf('%s: %d rows (expected %d)\n', path, numel(ids), numel(test_ids));
ok = isempty(problems);
if ~ok
    fprintf('REJECTED. The scorer would refuse this file:\n');
    fprintf('  - %s\n', problems);
    return
end
fprintf('ACCEPTED. The file has the right format. Predicted class counts:\n');
for c = classes
    fprintf('  %-22s %6d\n', c, sum(labels == c));
end
if numel(unique(labels)) == 1
    fprintf(['  note: every row has the same class. That is the untouched template, which scores\n' ...
             '  about 10 percent. Did you write your own predictions into it?\n']);
end
end
