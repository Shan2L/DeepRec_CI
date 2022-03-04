import os
import fire
import yaml
import parse
import xlwt


class Config(object):
    def __init__(self, config_path: str = "config.yaml"):
        self.curr_config_path = os.path.abspath(config_path)
        if not os.path.exists(self.curr_config_path):
            raise FileNotFoundError(
                "config file path in {} does not exist".format(self.curr_config_path))

        with open(self.curr_config_path, "r") as fp:
            config_maps = yaml.load(fp.read(), Loader=yaml.FullLoader)
            _patterns = config_maps["Patterns"]
            for _key, _value in _patterns.items():
                setattr(self, _key, _value)
        pass

    def __getitem__(self, item):
        return getattr(self, item, None)


config = Config()


class Executor:
    def __init__(self):
        self.wb = xlwt.Workbook(encoding='utf-8')
        self.ws = None

    def BM(self, log_path: str, execl_path: str):
        print(log_path)
        print(execl_path)
        print(config.start)
        _title = []
        _parse_flag = False
        _curr_target_name = ""
        _all_excel_data = []
        with open(log_path, "r") as fp:
            for _line in fp.readlines():
                _line = "".join(_char for _char in _line if _char.isprintable())
                _parse_start = parse.search(config.start, _line)
                _parse_end = parse.search(config.end, _line)
                # print("*{}*".format(_line))
                if _parse_start:
                    _parse_flag = True

                if _parse_end and _parse_flag:
                    _parse_flag = False
                    # store data to excel
                    if len(_all_excel_data) > 0:
                        self.ws = self.wb.add_sheet("UT_result")
                        _all_excel_data.insert(0, _title)
                        for i, j in [(i, j) for i in range(len(_all_excel_data)) for j in
                                     range(len(_all_excel_data[0]))]:
                            self.ws.write(i, j, _all_excel_data[i][j])
                            pass
                        self.wb.save(execl_path)
                        print(_all_excel_data)

                    _all_excel_data.clear()

                if _parse_flag:
                    # start parse BM datastore data
                    _curr_target_name="single_row"
                    _test_case = config[_curr_target_name]
                    if not _test_case:
                        continue
                    _target_patterns = _test_case["patterns"]
                    # print(_target_pattern)

                    _pattern1 = _target_patterns[0]
                    print(_pattern1)
                    _pattern2 = _target_patterns[1]
                    print(_pattern2)
                    _search = parse.search(_pattern1, _line) or parse.search(_pattern2, _line)
                    print(_search)
                    if _search:
                        print(1)
                        _title = [_item for _item in _search.named.keys()]
                        _all_excel_data.append([_item for _item in _search.named.values()])
                        #break

        pass


_executor = Executor()


class LogParser(object):

    def BM(self, log_path: str, excel_path: str = None):
        """
        Args:
            log_path: the log file path.
            excel_path: the execl file will be generated in this path.

        Returns:

        """
        log_path = os.path.abspath(log_path)
        if not os.path.exists(log_path):
            raise FileNotFoundError("log file path in {} does not exist".format(log_path))

        if not excel_path:
            excel_path = log_path

        parent_dir, _ = os.path.split(os.path.abspath(excel_path))

        if not os.path.exists(parent_dir):
            os.mkdir(parent_dir)

        _log_parent_dir, _log_file_name = os.path.split(log_path)
        _file_name, _ = os.path.splitext(_log_file_name)
        excel_path = os.path.join(_log_parent_dir, "{}.xls".format(_file_name))

        if os.path.exists(excel_path):
            os.remove(excel_path)

        _executor.BM(log_path, excel_path)
        pass


if __name__ == '__main__':
    fire.Fire(LogParser)
